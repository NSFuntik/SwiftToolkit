//
//  NSManagedObject+Database.swift
//  CoreDatabase
//
//  Provides extensions for NSManagedObject with enhanced querying capabilities.

import os.log
import Combine
import CoreData
import Foundation

// MARK: - ManagedObjectHelpers

extension NSManagedObject: ManagedObjectHelpers {}

public protocol ManagedObjectHelpers {}

// MARK: - Change

/// Represents changes to a specific managed object type
public struct Change<T: NSManagedObject> {
  /// Set of inserted object IDs
  public let inserted: Set<ObjectId<T>>
  /// Set of updated object IDs
  public let updated: Set<ObjectId<T>>
  /// Set of deleted object IDs
  public let deleted: Set<ObjectId<T>>
}

// MARK: - KeyPath Extensions

extension KeyPath {
  /// Converts KeyPath to string representation
  var asString: String {
    guard let path = _kvcKeyPathString else {
      fatalError("Cannot get string from keypath")
    }
    return path
  }
}

// MARK: - NSPredicate Extensions

public extension NSPredicate {
  /// Creates a predicate comparing a property with a value
  /// - Parameters:
  ///   - keyString: Property key path string
  ///   - value: Value to compare against
  /// - Returns: Configured predicate
  static func with<U>(_ keyString: String, _ value: U) -> NSPredicate {
    if let value = value as? CVarArg {
      return NSPredicate(format: "\(keyString) == %@", value as? NSNumber ?? value)
    } else if let value = value as? UUID {
      return NSPredicate(format: "\(keyString) == %@", value as CVarArg)
    } else if let value = value as? NSObject?, value == nil {
      return NSPredicate(format: "\(keyString) == nil")
    } else {
      fatalError("Unsupported type for filtering in predicate: \(type(of: value))")
    }
  }
}

// MARK: - ManagedObjectHelpers Extensions

public extension ManagedObjectHelpers where Self: NSManagedObject {
  /// Observes changes to this entity type
  /// - Parameter database: Database instance to observe
  /// - Returns: Publisher emitting changes
  static func didChange(_ database: Database) -> AnyPublisher<Change<Self>, Never> {
    objectsDidChange(database)
      .map {
        Change(
          inserted: Set($0.inserted.map { ObjectId<Self>($0) }),
          updated: Set($0.updated.map { ObjectId<Self>($0) }),
          deleted: Set($0.deleted.map { ObjectId<Self>($0) }))
      }
      .eraseToAnyPublisher()
  }

  /// Retrieves all objects of this type from the view context
  /// - Parameter database: Database instance
  /// - Returns: Array of objects
  @MainActor
  static func all(_ database: Database) -> [Self] {
    all(database.viewContext)
  }

  /// Retrieves all objects of this type from a context
  /// - Parameter ctx: Managed object context
  /// - Returns: Array of objects
  static func all(_ ctx: NSManagedObjectContext) -> [Self] {
    let request = NSFetchRequest<Self>()
    do {
      return try ctx.execute(request: request)
    } catch {
      os_log("Failed to fetch all objects: %{public}@", log: .default, type: .error, error.localizedDescription)
      return []
    }
  }

  /// Retrieves all objects sorted by objectID
  /// - Parameter database: Database instance
  /// - Returns: Sorted array of objects
  @MainActor
  static func allSorted(_ database: Database) -> [Self] {
    allSorted(database.viewContext)
  }

  /// Retrieves all objects sorted by objectID from a context
  /// - Parameter ctx: Managed object context
  /// - Returns: Sorted array of objects
  static func allSorted(_ ctx: NSManagedObjectContext) -> [Self] {
    allSortedBy(key: \.objectID.description, ctx: ctx)
  }

  /// Retrieves all objects sorted by a key path
  /// - Parameters:
  ///   - key: Key path to sort by
  ///   - ascending: Sort order
  ///   - database: Database instance
  /// - Returns: Sorted array of objects
  @MainActor
  static func allSortedBy<U>(
    key: KeyPath<Self, U>,
    ascending: Bool = true,
    _ database: Database) -> [Self] where U: Comparable {
    allSortedBy(key: key, ascending: ascending, ctx: database.viewContext)
  }

  /// Retrieves all objects sorted by a key path from a context
  /// - Parameters:
  ///   - key: Key path to sort by
  ///   - ascending: Sort order
  ///   - ctx: Managed object context
  /// - Returns: Sorted array of objects
  static func allSortedBy<U>(
    key: KeyPath<Self, U>,
    ascending: Bool = true,
    ctx: NSManagedObjectContext) -> [Self] where U: Comparable {
    let request = NSFetchRequest<Self>()
    request.sortDescriptors = [NSSortDescriptor(keyPath: key, ascending: ascending)]

    do {
      return try ctx.execute(request: request)
    } catch {
      os_log("Failed to fetch sorted objects: %{public}@", log: .default, type: .error, error.localizedDescription)
      return []
    }
  }

  /// Finds objects matching a key path value
  /// - Parameters:
  ///   - keyPath: Key path to match
  ///   - value: Value to match
  ///   - database: Database instance
  /// - Returns: Matching objects
  @MainActor
  static func find<U>(
    _ keyPath: KeyPath<Self, U>,
    _ value: U,
    _ database: Database) -> [Self] {
    find(keyPath, value, ctx: database.viewContext)
  }

  /// Finds objects matching a key path value in a context
  /// - Parameters:
  ///   - keyPath: Key path to match
  ///   - value: Value to match
  ///   - ctx: Managed object context
  /// - Returns: Matching objects
  static func find<U>(
    _ keyPath: KeyPath<Self, U>,
    _ value: U,
    ctx: NSManagedObjectContext) -> [Self] {
    find(predicate: .with(keyPath.asString, value), ctx: ctx)
  }

  /// Finds objects matching a predicate
  /// - Parameters:
  ///   - predicate: Predicate to match
  ///   - database: Database instance
  /// - Returns: Matching objects
  @MainActor
  static func find(
    predicate: NSPredicate,
    _ database: Database) -> [Self] {
    find(predicate: predicate, ctx: database.viewContext)
  }

  /// Finds objects matching a predicate in a context
  /// - Parameters:
  ///   - predicate: Predicate to match
  ///   - ctx: Managed object context
  /// - Returns: Matching objects
  static func find(
    predicate: NSPredicate,
    ctx: NSManagedObjectContext) -> [Self] {
    let request = NSFetchRequest<Self>()
    request.predicate = predicate

    do {
      return try ctx.execute(request: request)
    } catch {
      os_log("Failed to fetch with predicate: %{public}@", log: .default, type: .error, error.localizedDescription)
      return []
    }
  }

  /// Finds first object matching a key path value
  /// - Parameters:
  ///   - keyPath: Key path to match
  ///   - value: Value to match
  ///   - database: Database instance
  /// - Returns: First matching object
  @MainActor
  static func findFirst<U>(
    _ keyPath: KeyPath<Self, U>,
    _ value: U,
    _ database: Database) -> Self? {
    findFirst(keyPath, value, ctx: database.viewContext)
  }

  /// Finds first object matching a key path value in a context
  /// - Parameters:
  ///   - keyPath: Key path to match
  ///   - value: Value to match
  ///   - ctx: Managed object context
  /// - Returns: First matching object
  static func findFirst<U>(
    _ keyPath: KeyPath<Self, U>,
    _ value: U,
    ctx: NSManagedObjectContext) -> Self? {
    findFirst(.with(keyPath.asString, value), ctx: ctx)
  }

  /// Finds first object matching a predicate
  /// - Parameters:
  ///   - predicate: Predicate to match
  ///   - ctx: Managed object context
  /// - Returns: First matching object
  static func findFirst(
    _ predicate: NSPredicate,
    ctx: NSManagedObjectContext) -> Self? {
    let request = NSFetchRequest<Self>()
    request.fetchLimit = 1
    request.predicate = predicate

    do {
      return try ctx.execute(request: request).first
    } catch {
      os_log("Failed to fetch first with predicate: %{public}@", log: .default, type: .error, error.localizedDescription)
      return nil
    }
  }
}

// MARK: - NSManagedObject Extensions

public extension NSManagedObject {
  /// Deletes the object from its context
  func delete() {
    managedObjectContext?.delete(self)
  }

  /// Checks if the object is deleted
  var isObjectDeleted: Bool {
    managedObjectContext == nil || isDeleted
  }

  /// Gets the permanent object ID
  var permanentObjectID: NSManagedObjectID {
    var objectID = self.objectID

    if objectID.isTemporaryID {
      try? managedObjectContext?.obtainPermanentIDs(for: [self])
      objectID = self.objectID
    }
    return objectID
  }

  /// Observes changes to this entity type
  static func objectsDidChange(_ database: Database) -> AnyPublisher<Database.Change, Never> {
    [self].objectsDidChange(database)
  }

  /// Observes count changes to this entity type
  static func objectsCountChanged(_ database: Database) -> AnyPublisher<Database.Change, Never> {
    [self].objectsCountChanged(database)
  }
}

// MARK: - Collection Extensions

public extension Collection where Element == NSManagedObject.Type {
  /// Observes changes to multiple entity types
  func objectsDidChange(_ database: Database) -> AnyPublisher<Database.Change, Never> {
    database.objectsDidChange
      .filter { change in
        contains { item in
          guard let name = item.entity().name else { return false }
          return change.classes.contains(name)
        }
      }
      .eraseToAnyPublisher()
  }

  /// Observes count changes to multiple entity types
  func objectsCountChanged(_ database: Database) -> AnyPublisher<Database.Change, Never> {
    database.objectsDidChange
      .filter { $0.deleted.count > 0 || $0.inserted.count > 0 }
      .eraseToAnyPublisher()
  }
}
