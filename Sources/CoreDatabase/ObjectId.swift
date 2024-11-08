//
//  ObjectId.swift
//  CoreDatabase
//
//  Provides type-safe object identifier handling for managed objects.

import CoreData

// MARK: - WithObjectId Protocol

/// Protocol for objects that can provide their object ID
public protocol WithObjectId {}

public extension WithObjectId where Self: NSManagedObject {
  /// Gets a type-safe object identifier
  var getObjectId: ObjectId<Self> {
    ObjectId(self)
  }
}

extension NSManagedObject: WithObjectId {}

// MARK: - ObjectId

/// Type-safe wrapper for NSManagedObjectID
public struct ObjectId<T: NSManagedObject>: Hashable {
  /// The underlying Core Data object ID
  public let objectId: NSManagedObjectID

  /// Creates an ObjectId from a managed object
  /// - Parameter object: Source managed object
  /// - Warning: This method ensures the object has a permanent ID before accessing it.
  public init(_ object: T) {
    if object.objectID.isTemporaryID {
      do {
            try object.managedObjectContext?.obtainPermanentIDs(for: [object])
        } catch {
        print("Warning: Could not obtain permanent object ID")
      }
    }
    objectId = object.permanentObjectID
  }

  /// Creates an ObjectId from a Core Data object ID
  /// - Parameter objectId: Source Core Data object ID
  init(_ objectId: NSManagedObjectID) {
    self.objectId = objectId
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(objectId)
  }

  /// Retrieves the object from the view context
  /// - Parameter database: Database instance
  /// - Returns: Retrieved object if found
  @MainActor
  public func object(_ database: Database) -> T? {
    object(database.viewContext)
  }

  /// Retrieves the object from a specific context
  /// - Parameter ctx: Managed object context
  /// - Returns: Retrieved object if found
  public func object(_ ctx: NSManagedObjectContext) -> T? {
    T.find(\.objectID, objectId, ctx: ctx).first
  }
}

// MARK: - Sequence Extensions

public extension Sequence {
  /// Retrieves objects from the view context
  /// - Parameter database: Database instance
  /// - Returns: Array of retrieved objects
  @MainActor
  func objects<U: NSManagedObject>(_ database: Database) -> [U] where Element == ObjectId<U> {
    objects(database.viewContext)
  }

  /// Retrieves objects from a specific context
  /// - Parameter ctx: Managed object context
  /// - Returns: Array of retrieved objects
  func objects<U: NSManagedObject>(_ ctx: NSManagedObjectContext) -> [U] where Element == ObjectId<U> {
    compactMap { $0.object(ctx) }
  }

  /// Gets URI representations of object IDs
  /// - Returns: Array of URIs
  func uri<U: NSManagedObject>() -> [URL] where Element == ObjectId<U> {
    map { $0.objectId.uriRepresentation() }
  }
}

public extension Sequence where Element: NSManagedObject {
  /// Gets type-safe object IDs for a sequence of managed objects
  var ids: [ObjectId<Element>] {
    map { $0.getObjectId }
  }
}
