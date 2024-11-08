//
//  StoreDescription.swift
//  CoreDatabase
//
//  Provides configuration utilities for CoreData persistent stores.

import CoreData
import CloudKit
import Foundation

public extension NSPersistentStoreDescription {
  /// Represents store configuration options
  enum Configuration {
    case local(name: String)
    case cloud(name: String, identifier: String)

    var name: String {
      switch self {
      case let .local(name), let .cloud(name, _):
        return name
      }
    }
  }

  /// Creates a local data store description
  /// - Parameters:
  ///   - configuration: Optional store configuration
  ///   - setup: Custom setup closure
  /// - Returns: Configured store description
  static func localData(
    _ configuration: Configuration? = nil,
    setup: (NSPersistentStoreDescription) -> Void = { _ in }) -> NSPersistentStoreDescription {
    description(
      configuration,
      url: URL(fileURLWithPath: applicationSupportDirectory + "/" + (configuration?.name ?? "") + databaseFileName),
      setup: setup)
  }

  @available(*, deprecated, message: "Use localData(), data file has been renamed")
  static func dataStore(_ configuration: Configuration? = nil,
                        setup: (NSPersistentStoreDescription) -> Void = { _ in }) -> NSPersistentStoreDescription {
    description(
      configuration,
      url: URL(fileURLWithPath: applicationSupportDirectory + "/" + databaseFileName + (configuration?.name ?? "")),
      setup: setup)
  }

  /// Creates cloud-enabled store descriptions with sharing support
  /// - Parameters:
  ///   - name: Store name
  ///   - identifier: CloudKit container identifier
  ///   - setup: Custom setup closure for private and shared stores
  /// - Returns: Array of configured store descriptions
  static func cloudWithShare(
    _ name: String,
    identifier: String,
    setup: (_ cloud: NSPersistentStoreDescription,
            _ share: NSPersistentStoreDescription) -> Void = { _, _ in }) -> [NSPersistentStoreDescription] {
    let privatePath = applicationSupportDirectory + "/" + name + databaseFileName
    let sharedPath = applicationSupportDirectory + "/shared" + name + databaseFileName

    let privateDescription = description(
      .cloud(name: name, identifier: identifier),
      url: URL(fileURLWithPath: privatePath)) { description in
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
      }

    let sharedDescription = privateDescription.copy() as! NSPersistentStoreDescription
    sharedDescription.url = URL(fileURLWithPath: sharedPath)

    setup(privateDescription, sharedDescription)

    let sharedStoreOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: identifier)
    sharedStoreOptions.databaseScope = .shared
    sharedDescription.cloudKitContainerOptions = sharedStoreOptions

    return [privateDescription, sharedDescription]
  }

  /// Creates a transient store description for testing
  /// - Parameters:
  ///   - configuration: Optional store configuration
  ///   - setup: Custom setup closure
  /// - Returns: Configured transient store description
  static func transientStore(
    _ configuration: Configuration? = nil,
    setup: (NSPersistentStoreDescription) -> Void = { _ in }) -> NSPersistentStoreDescription {
    let store = description(
      configuration,
      url: URL(string: "memory://")!,
      setup: setup)
    store.type = NSInMemoryStoreType
    return store
  }

  /// Base method for creating store descriptions
  private static func description(
    _ configuration: Configuration?,
    url: URL,
    setup: (NSPersistentStoreDescription) -> Void = { _ in }) -> NSPersistentStoreDescription {
    let store = NSPersistentStoreDescription(url: url)
    store.configuration = configuration?.name ?? "PF_DEFAULT_CONFIGURATION_NAME"

    if case let .cloud(_, identifier) = configuration {
      store.cloudKitContainerOptions = .init(containerIdentifier: identifier)
    }

    store.shouldMigrateStoreAutomatically = true
    store.shouldInferMappingModelAutomatically = true

    setup(store)
    return store
  }

  /// Copies store file from a given URL
  /// - Parameter url: Source URL
  /// - Throws: File operation errors
  func copyStoreFileFrom(url: URL) throws {
    guard let currentUrl = self.url,
          FileManager.default.fileExists(atPath: url.path) else { return }
    try FileManager.default.copyItem(at: url, to: currentUrl)
  }

  /// Removes all store files
  func removeStoreFiles() {
    guard let url = url else { return }

    let directory = url.deletingLastPathComponent()
    guard let files = try? FileManager.default.contentsOfDirectory(atPath: directory.path) else { return }

    files.filter { $0.contains(Self.databaseFileName) }
      .forEach { fileName in
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(fileName))
      }
  }
}

// MARK: - Private Extensions

private extension NSPersistentStoreDescription {
  /// Database file name based on process name
  static var databaseFileName: String {
    ProcessInfo.processInfo.processName
      .trimmingCharacters(in: .whitespacesAndNewlines) + ".sqlite"
  }

  /// Application support directory path
  static var applicationSupportDirectory: String {
    let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
    let dir = path + "/" + Bundle.main.bundleIdentifier!

    try? FileManager.default.createDirectory(
      atPath: dir,
      withIntermediateDirectories: true,
      attributes: nil)

    return dir
  }
}
