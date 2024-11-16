//
//  Fetchable.swift
//  CoreDatabase
//
//  Provides protocols for fetching and updating managed objects with robust error handling.

import Combine
import CoreData
import Foundation
import os

// MARK: - FetchableError

/// Comprehensive error types for Fetchable protocol operations
public enum FetchableError: Error {
  case invalidIdentifier(message: String)
  case invalidSource(message: String)
  case updateFailed(reason: String)
  case parseFailure(key: String, value: Any?)
}

// MARK: - Uploadable

/// Protocol for objects that can be converted to a source format
public protocol Uploadable: Fetchable {
  /// Converts the object to its source representation
  var toSource: Source { get }
}

// MARK: - Fetchable

/// Protocol defining requirements for fetching and updating managed objects with enhanced error handling
public protocol Fetchable {
  /// Type representing the unique identifier
  associatedtype Id
  /// Type representing the source data format
  associatedtype Source

  /// Unique identifier for the object
  var uid: Id { get set }

  /// Updates the object with source data, with potential error throwing
  /// - Parameter source: Source data to update from
  /// - Throws: FetchableError if update fails
  func update(_ source: Source) throws

  /// Extracts unique identifier from source data
  /// - Parameter source: Source data to extract from
  /// - Returns: Extracted identifier
  /// - Throws: FetchableError if identifier extraction fails
  static func uid(from source: Source) throws -> Id

  /// Validates the unique identifier
  /// - Parameter uid: Identifier to validate
  /// - Returns: True if identifier is valid
  /// - Throws: FetchableError if identifier is invalid
  static func isValid(source: Source) -> Bool

  /// Validates the source data
  /// - Parameter source: Source data to validate
  /// - Returns: True if source data is valid
  /// - Throws: FetchableError if source is invalid
  static func validateSource(_ source: Source) throws -> Bool
}

// MARK: - Fetchable Default Implementations

extension Fetchable where Id: Equatable {
  /// Default source validation - always returns true
  public static func validateSource(_ source: Source) throws -> Bool { true }
}

extension Fetchable {
  public static func isValid(source: Source) -> Bool { true }
}

extension Fetchable {
  public static func isValid(uid: Id?) -> Bool { uid != nil }
}

extension Fetchable where Source == [String: Any], Id == String? {
  /// Extracts String identifier from dictionary source
  public static func uid(from source: [String: Any]) -> String? {
    var uid = source["uid"] as? String ?? source["id"] as? String

    if uid == nil, let id = source["id"] as? Int64 {
      uid = "\(id)"
    }

    if uid == nil {
      os_log(
        "ID not found in source for type: %{public}@",
        log: .default,
        type: .error,
        String(describing: self)
      )
    }
    return uid
  }
}

extension Fetchable where Source == [String: Any], Id == UUID? {
  /// Extracts UUID identifier from dictionary source
  public static func uid(from source: [String: Any]) -> UUID? {
    if let uid = source["uid"] as? String ?? source["id"] as? String,
      let uuid = UUID(uuidString: uid)
    {
      return uuid
    }

    os_log(
      "UUID not found in source for type: %{public}@",
      log: .default,
      type: .error,
      String(describing: self)
    )
    return nil
  }
}

// MARK: - Fetchable Parsing Extensions

extension Fetchable {
  /// Parses optional values from dictionary
  /// - Parameters:
  ///   - dict: Source dictionary
  ///   - keys: Array of keypaths and corresponding source keys
  ///   - dateConverted: Optional date conversion closure
  public func parse(
    _ dict: [String: Any],
    _ keys: [(dbKey: ReferenceWritableKeyPath<Self, Date?>, serviceKey: String)],
    dateConverted: ((String) -> (Date?))? = nil
  ) {
    for key in keys {
      if let value = dict[key.serviceKey] {
        if let value = value as? Date {
          self[keyPath: key.dbKey] = value
        } else if let value = value as? String, let dateConverted = dateConverted?(value) {
          self[keyPath: key.dbKey] = dateConverted
        } else {
          self[keyPath: key.dbKey] = nil
        }
      }
    }
  }

  /// Parses non-optional values from dictionary
  /// - Parameters:
  ///   - dict: Source dictionary
  ///   - keys: Array of keypaths and corresponding source keys
  public func parse<U>(
    _ dict: [String: Any],
    _ keys: [(dbKey: ReferenceWritableKeyPath<Self, U>, serviceKey: String)]
  ) {
    for key in keys {
      guard let value = dict[key.serviceKey] else { continue }

      if let value = value as? U {
        self[keyPath: key.dbKey] = value
      } else if let value = value as? String {
        parseStringValue(value, for: key.dbKey)
      } else if let dbKey = key.dbKey as? ReferenceWritableKeyPath<Self, Float>,
        let value = value as? Double
      {
        self[keyPath: dbKey] = Float(value)
      }
    }
  }

  /// Parses string value to appropriate type
  private func parseStringValue<U>(_ value: String, for keyPath: ReferenceWritableKeyPath<Self, U>) {
    if let dbKey = keyPath as? ReferenceWritableKeyPath<Self, Float> {
      self[keyPath: dbKey] = Float(value) ?? 0
    } else if let dbKey = keyPath as? ReferenceWritableKeyPath<Self, Double> {
      self[keyPath: dbKey] = Double(value) ?? 0
    } else if let dbKey = keyPath as? ReferenceWritableKeyPath<Self, Bool> {
      self[keyPath: dbKey] = value == "1" || value == "true"
    }
  }
}

// MARK: - NSManagedObject Extensions

extension Fetchable where Self: NSManagedObject, Source == [String: Any] {
  /// Parses array of source data into managed objects
  /// - Parameters:
  ///   - array: Array of source data
  ///   - additional: Optional closure for additional processing
  ///   - deleteOldItems: Whether to delete items not in source
  ///   - ctx: Managed object context
  /// - Returns: Array of updated managed objects
  public static func parse(
    _ array: [Source]?,
    additional: ((Self, Source) -> Void)? = nil,
    deleteOldItems: Bool = false,
    ctx: NSManagedObjectContext
  ) -> [Self] {
    guard let array = array else { return [] }

    var resultSet = Set<NSManagedObjectID>()
    var result: [Self] = []
    var oldItems = deleteOldItems ? Set(Self.all(ctx)) : []

    for source in array {
      if let object = findAndUpdate(source, ctx: ctx),
        !resultSet.contains(object.objectID)
      {
        oldItems.remove(object)
        resultSet.insert(object.objectID)
        result.append(object)
        additional?(object, source)
      }
    }

    oldItems.forEach { $0.delete() }
    return result
  }

  /// Finds or creates a placeholder object with given ID
  /// - Parameters:
  ///   - uid: Unique identifier
  ///   - ctx: Managed object context
  /// - Returns: Found or created object
  public static func findOrCreatePlaceholder(uid: Id, ctx: NSManagedObjectContext) -> Self {
    if let found = findFirst(.with("uid", uid), ctx: ctx) {
      return found
    }
    var object = self.init(context: ctx)
    object.uid = uid
    return object
  }

  /// Finds and updates an object with source data
  /// - Parameters:
  ///   - source: Source data
  ///   - ctx: Managed object context
  /// - Returns: Updated object if successful
  public static func findAndUpdate(_ source: Source?, ctx: NSManagedObjectContext) -> Self? {
    guard let source = source,
      (try? validateSource(source)) == true,
      let uid = try? uid(from: source),
      isValid(uid: uid)
    else {
      return nil
    }

    let object = findOrCreatePlaceholder(uid: uid, ctx: ctx)
    try? object.update(source)
    return object
  }
}

// MARK: - Dictionary Source Extensions

extension Fetchable where Self: NSManagedObject, Source == [String: Any] {
  /// Parses and updates a related object
  public func parse<T: Fetchable & NSManagedObject>(
    _ dict: [String: Any],
    _ dbKey: ReferenceWritableKeyPath<Self, T?>,
    _ serviceKey: String,
    deleteOldItem: Bool = false
  ) where T.Source == [String: Any] {
    guard let value = dict[serviceKey],
      let ctx = managedObjectContext
    else { return }

    let oldItem = self[keyPath: dbKey]
    let updated = T.findAndUpdate(value as? [String: Any], ctx: ctx)
    self[keyPath: dbKey] = updated

    if oldItem != updated, deleteOldItem {
      oldItem?.delete()
    }
  }

  /// Parses and updates a set of related objects
  public func parse<T: Fetchable & NSManagedObject>(
    _ type: T.Type,
    _ dict: [String: Any],
    _ dbKey: ReferenceWritableKeyPath<Self, NSSet?>,
    _ serviceKey: String,
    additional: ((T, [String: Any]) -> Void)? = nil,
    deleteOldItems: Bool = false
  ) where T.Source == [String: Any] {
    guard let value = dict[serviceKey],
      let ctx = managedObjectContext
    else { return }

    let array: [[String: Any]] = {
      if let value = value as? [[String: Any]] {
        return value
      } else if let value = value as? [Int64] {
        return value.map { ["id": $0] }
      }
      return []
    }()

    let oldItems: Set<T> = {
      if let items = self[keyPath: dbKey] {
        return items as! Set<T>
      }
      return .init()
    }()

    let updatedItems = Set(T.parse(array, additional: additional, ctx: ctx))
    self[keyPath: dbKey] = NSSet(set: updatedItems)

    if deleteOldItems {
      oldItems.subtracting(updatedItems).forEach { $0.delete() }
    }
  }
}
