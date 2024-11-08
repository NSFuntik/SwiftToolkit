//
//  Database.swift
//  CoreDatabase
//
//  Provides a comprehensive CoreData and CloudKit integration layer

import os.log
import Combine
import CoreData
import CloudKit
import Foundation

/// A robust database management actor providing async/await CoreData operations
public actor Database: NSObject, Sendable {
  /// Manages task synchronization to prevent concurrent modifications
  private actor TaskSync {
    private var task: Task<Any, Error>?

    /// Runs a block ensuring sequential execution
    /// - Parameter block: Async throwing closure to execute
    /// - Returns: Result of the block
    public func run<Success>(_ block: @Sendable @escaping () async throws -> Success) async throws -> Success {
      task = Task { [task] in
        _ = await task?.result
        return try await block() as Any
      }
      return try await task!.value as! Success
    }
  }

  /// The logger for database operations
  let logger: DatabaseLogger = DefaultDatabaseLogger()

  /// Synchronizes edit operations to prevent race conditions
  private let editSync: Database.TaskSync = TaskSync()

  /// Dedicated queue for processing history changes
  private let historyQueue = DispatchQueue(label: "database.history")

  /// The persistent CloudKit container managing data storage
  public let container: NSPersistentCloudKitContainer

  /// The main view context for reading data on the main thread
  @MainActor
  public var viewContext: NSManagedObjectContext {
    container.viewContext
  }

  /// A dedicated writer context for background operations
  public nonisolated let writerContext: NSManagedObjectContext

  /// Tracks observers to prevent premature deallocation
  private var observers: [AnyCancellable] = []

  /// Initializes a new Database instance
  /// - Parameters:
  ///   - storeDescriptions: Configurations for persistent stores
  ///   - modelBundle: Bundle containing the Core Data model
  public init(
    storeDescriptions: [NSPersistentStoreDescription] = [.localData()],
    modelBundle: Bundle = Bundle.main) {
    let model = NSManagedObjectModel.mergedModel(from: [modelBundle])!
    container = NSPersistentCloudKitContainer(name: "Database", managedObjectModel: model)

    container.viewContext.mergePolicy = NSRollbackMergePolicy
    container.viewContext.name = "view"
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.persistentStoreDescriptions = storeDescriptions

    writerContext = container.newBackgroundContext()
    writerContext.automaticallyMergesChangesFromParent = true
    writerContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    super.init()

    Task {
      await self.setupChangeTracking(for: storeDescriptions)
    }
  }

  /// Configures change tracking based on store description
  /// - Parameter storeDescriptions: Persistent store configurations
  private func setupChangeTracking(for storeDescriptions: [NSPersistentStoreDescription]) {
    var trackedObservers: [AnyCancellable] = []

    if storeDescriptions.contains(where: { $0.options[NSPersistentHistoryTrackingKey] as? NSNumber == true }) {
      NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
        .sink { [weak self] in self?.didRemoteChange(notification: $0) }
        .store(in: &trackedObservers)
    } else {
      NotificationCenter.default.publisher(for: NSManagedObjectContext.didMergeChangesObjectIDsNotification)
        .sink { [weak self] notification in
          Task { await self?.didMerge(notification) }
        }
        .store(in: &trackedObservers)
    }

    Task { [weak self] in
      await self?.store(trackedObservers)
      await self?.setupPersistentStores()
    }
  }

  /// Stores observers to prevent premature deallocation
  /// - Parameter observers: Cancellable observers
  private func store(_ observers: [AnyCancellable]) {
    self.observers = observers
  }

  /// Sets up persistent stores with error handling
  private func setupPersistentStores() {
    container.loadPersistentStores { description, error in
      if let error = error {
        os_log(
          "Error creating persistent store: %@ for configuration %@",
          log: .default,
          type: .error,
          error.localizedDescription,
          description.configuration ?? "Unknown")

        // Handle migration failures
        if (error as NSError).code == 134_110 {
          description.removeStoreFiles()
          self.setupPersistentStores()
        }
      } else {
        os_log(
          "Store added successfully: %@",
          log: .default,
          type: .info,
          description.url?.path ?? "Unknown path")
      }
    }
  }

  /// Retrieves the persistent store for private data
  public nonisolated var privateStore: NSPersistentStore? {
    let description: NSPersistentStoreDescription? = container.persistentStoreDescriptions.first {
      if let options: NSPersistentCloudKitContainerOptions = $0.cloudKitContainerOptions {
        return options.databaseScope == .private
      }
      return true
    }

    if let url = description?.url {
      return container.persistentStoreCoordinator.persistentStore(for: url)
    }
    return nil
  }

  /// Retrieves the persistent store for shared data
  public nonisolated var sharedStore: NSPersistentStore? {
    if let url: URL = container.persistentStoreDescriptions.first(where: {
      $0.cloudKitContainerOptions?.databaseScope == .shared
    })?.url {
      return container.persistentStoreCoordinator.persistentStore(for: url)
    }
    return nil
  }

  /// Manages persistent history token for tracking changes
  /// - Parameter storeUUID: Unique identifier for the store
  /// - Returns: Stored history token or nil
  private nonisolated func historyToken(with storeUUID: String) -> NSPersistentHistoryToken? {
    if let data = UserDefaults.standard.data(forKey: "HistoryToken" + storeUUID) {
      return try? NSKeyedUnarchiver.unarchivedObject(
        ofClass: NSPersistentHistoryToken.self,
        from: data)
    }
    return nil
  }

  /// Updates the history token for a specific store
  /// - Parameters:
  ///   - storeUUID: Unique identifier for the store
  ///   - newToken: New history token to store
  private nonisolated func updateHistoryToken(
    with storeUUID: String,
    newToken: NSPersistentHistoryToken) {
    let data = try? NSKeyedArchiver.archivedData(
      withRootObject: newToken,
      requiringSecureCoding: true)
    UserDefaults.standard.set(data, forKey: "HistoryToken" + storeUUID)
  }

  /// Represents changes in the database
  public struct Change: Sendable {
    /// Entity class names that changed
    public let classes: Set<String>
    /// Inserted object IDs
    public let inserted: Set<NSManagedObjectID>
    /// Updated object IDs
    public let updated: Set<NSManagedObjectID>
    /// Deleted object IDs
    public let deleted: Set<NSManagedObjectID>
  }

  /// Publisher for objects that have changed
  public nonisolated let objectsDidChange = PassthroughSubject<Change, Never>()

  /// Publisher for share changes
  public nonisolated let sharePublisher = PassthroughSubject<Void, Never>()

  /// Handles remote changes in the persistent store
  /// - Parameter notification: Notification about remote store changes
  private nonisolated func didRemoteChange(notification: Notification) {
    guard let storeUUID = notification.userInfo?[NSStoreUUIDKey] as? String,
          let privateStore = privateStore,
          let sharedStore = sharedStore,
          privateStore.identifier == storeUUID ||
          sharedStore.identifier == storeUUID else {
      os_log(
        "Ignoring store remote change notification due to invalid store UUID",
        log: .default,
        type: .debug)
      return
    }

    Task {
      try await processRemoteChanges(storeUUID: storeUUID)
    }
  }

  /// Processes remote changes for a specific store
  /// - Parameter storeUUID: Unique identifier for the store
  private func processRemoteChanges(storeUUID: String) async throws {
    try await fetch { ctx in
      try self.historyQueue.sync { [weak self] in
        guard let self = self,
              let privateStore = self.privateStore,
              let sharedStore = self.sharedStore else {
          return
        }
        let lastHistoryToken: NSPersistentHistoryToken? = self.historyToken(with: storeUUID)
        let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
        request.fetchRequest = NSPersistentHistoryTransaction.fetchRequest

        request.affectedStores = [
          privateStore.identifier == storeUUID ? privateStore :
            sharedStore.identifier == storeUUID ? sharedStore : nil,
        ].compactMap { $0 }

        guard let result = try ctx.execute(request) as? NSPersistentHistoryResult,
              let transactions = result.result as? [NSPersistentHistoryTransaction] else {
          return
        }

        // Handle share changes or process transactions
        if transactions.isEmpty { // when transaction is empty it looks like CKShare is changed
          Task { @MainActor in
            self.sharePublisher.send()
          }
        } else {
          Task { [weak self] in
            guard let self = self else { return }
            try await self.processHistoryTransactions(transactions, storeUUID: storeUUID)
          }
        }
      }
    }
  }

  /// Processes history transactions and notifies about changes
  /// - Parameters:
  ///   - transactions: Persistent history transactions
  ///   - storeUUID: Unique identifier for the store
  private func processHistoryTransactions(
    _ transactions: [NSPersistentHistoryTransaction],
    storeUUID: String) throws {
    // Update history token
    if let newToken: NSPersistentHistoryToken = transactions.last?.token {
      updateHistoryToken(with: storeUUID, newToken: newToken)
    }

    // Collect changes
    var classes = Set<String>()
    var inserted = Set<NSManagedObjectID>()
    var updated = Set<NSManagedObjectID>()
    var deleted = Set<NSManagedObjectID>()

    for transaction in transactions {
      processTransactionChanges(
        transaction,
        classes: &classes,
        inserted: &inserted,
        updated: &updated,
        deleted: &deleted)
    }

    // Notify about changes
    if !classes.isEmpty {
      Task { @MainActor [
        classes,
        inserted,
        updated,
        deleted
      ] in
        objectsDidChange.send(
          Change(
            classes: classes,
            inserted: inserted,
            updated: updated,
            deleted: deleted)
        )
      }
    }
  }

  /// Processes changes within a single transaction
  /// - Parameters:
  ///   - transaction: Persistent history transaction
  ///   - classes: Mutable set of changed entity classes
  ///   - inserted: Mutable set of inserted object IDs
  ///   - updated: Mutable set of updated object IDs
  ///   - deleted: Mutable set of deleted object IDs
  private func processTransactionChanges(
    _ transaction: NSPersistentHistoryTransaction,
    classes: inout Set<String>,
    inserted: inout Set<NSManagedObjectID>,
    updated: inout Set<NSManagedObjectID>,
    deleted: inout Set<NSManagedObjectID>) {
    var others = Set<NSPersistentHistoryChange>()

    transaction.changes?.forEach { change in
      guard let className: String = change.changedObjectID.entity.name else { return }

      if change.changeType == .delete {
        classes.insert(className)
        deleted.insert(change.changedObjectID)
      } else {
        others.insert(change)
      }
    }

    others.forEach { change in
      guard !deleted.contains(change.changedObjectID),
            let className = change.changedObjectID.entity.name else { return }

      classes.insert(className)

      switch change.changeType {
      case .insert:
        inserted.insert(change.changedObjectID)
      case .update:
        updated.insert(change.changedObjectID)
      default:
        break
      }
    }
  }

  /// Processes local changes after merge
  private nonisolated func didMerge(_ notification: Notification) async {
    if let context: NSManagedObjectContext = notification.object as? NSManagedObjectContext,
       await context == viewContext,
       let userInfo: [AnyHashable: Any] = notification.userInfo {
      var classes = Set<String>()

      let extract: (String) -> Set<NSManagedObjectID> = { key in
        let set: Set<NSManagedObjectID> = userInfo[key] as? Set<NSManagedObjectID> ?? Set()

        return Set(set.compactMap { objectId in
          guard let className = objectId.entity.name else { return nil }

          if className.hasPrefix("NSCK") { return nil } // skip system items

          classes.insert(className)
          return objectId
        })
      }

      let inserted: Set<NSManagedObjectID> = extract("inserted_objectIDs")
      let updated: Set<NSManagedObjectID> = extract("updated_objectIDs")
      let deleted: Set<NSManagedObjectID> = extract("deleted_objectIDs")

      if classes.count > 0 {
        Task { @MainActor [classes] in
          objectsDidChange.send(Change(classes: classes,
                                       inserted: inserted,
                                       updated: updated,
                                       deleted: deleted))
        }
      }
    }
  }

  @discardableResult
  nonisolated func onEdit<T>(_ closure: @escaping () async throws -> T) async throws -> T {
    try await editSync.run {
      try await closure()
    }
  }

  public nonisolated func idFor(uriRepresentation: URL) -> NSManagedObjectID? {
    container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: uriRepresentation)
  }

  public nonisolated func createPrivateContext(mergeChanges: Bool) -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    context.transactionAuthor = "app"
    context.automaticallyMergesChangesFromParent = mergeChanges
    context.parent = writerContext
    return context
  }

  public nonisolated func createPrivateContext() -> NSManagedObjectContext {
    createPrivateContext(mergeChanges: false)
  }
}
