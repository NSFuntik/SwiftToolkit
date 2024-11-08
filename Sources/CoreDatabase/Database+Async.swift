//
//  Database+Async.swift
//  Database
//
//  Provides async/await extensions for Database operations.

import CoreData
import Foundation

// MARK: - ValueOnMoc Protocol

/// Protocol for managed objects that can be accessed asynchronously
public protocol ValueOnMoc {}

public extension ValueOnMoc where Self: NSManagedObject {
  /// Async accessor for managed object properties
  var async: AsyncValue<Self> { AsyncValue(value: self) }
}

// MARK: - AsyncValue

/// Wrapper providing async access to managed object properties
@dynamicMemberLookup
public struct AsyncValue<Value: NSManagedObject> {
  fileprivate let value: Value

  public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> () async throws -> T {
    { try await value.onMoc { value[keyPath: keyPath] } }
  }
}

// MARK: - NSManagedObject Extensions

extension NSManagedObject: ValueOnMoc {}

public extension NSManagedObject {
  /// Executes a block on the object's managed object context
  /// - Parameter block: Block to execute
  /// - Returns: Result of the block
  func onMoc<T>(_ block: @escaping () -> T) async throws -> T {
    guard let ctx = managedObjectContext else {
      throw CancellationError()
    }

    if #available(iOS 15, macOS 12, *) {
      return await ctx.perform { block() }
    } else {
      return await withCheckedContinuation { continuation in
        ctx.perform {
          continuation.resume(with: .success(block()))
        }
      }
    }
  }
}

// MARK: - Database Extensions

public extension Database {
  /// Performs an edit operation in a private context
  /// - Parameter closure: Edit operation closure
  /// - Returns: Result of the operation
  func edit<R>(_ closure: @escaping (_ ctx: NSManagedObjectContext) throws -> R) async throws -> R {
    try await onEdit { [weak self] in
      guard let self = self else {
        throw CancellationError()
      }
      let context = self.createPrivateContext()

      if #available(iOS 15, macOS 12, *) {
        return try await context.perform {
          let result = try closure(context)
          context.saveAll()
          return result
        }
      } else {
        return try await withCheckedThrowingContinuation { continuation in
          context.perform {
            do {
              let result = try closure(context)
              context.saveAll()
              continuation.resume(returning: result)
            } catch {
              continuation.resume(throwing: error)
            }
          }
        }
      }
    }
  }

  /// Performs a non-throwing edit operation
  func edit<R>(_ closure: @escaping (_ ctx: NSManagedObjectContext) -> R) async -> R {
    (try? await onEdit { [weak self] in
      guard let self = self else {
        throw CancellationError()
      }
      let context = createPrivateContext()

      if #available(iOS 15, macOS 12, *) {
        return await context.perform {
          let result = closure(context)
          context.saveAll()
          return result
        }
      } else {
        return await withCheckedContinuation { continuation in
          context.perform {
            let result = closure(context)
            context.saveAll()
            continuation.resume(returning: result)
          }
        }
      }
    }) ?? closure(createPrivateContext())
  }

  /// Edits a specific object by ID
  func edit<T, R>(
    _ objectId: ObjectId<T>,
    _ closure: @escaping (T, _ ctx: NSManagedObjectContext) throws -> R) async throws -> R {
    try await edit { ctx in
      guard let object = objectId.object(ctx) else {
        throw CancellationError()
      }
      return try closure(object, ctx)
    }
  }

  /// Edits a specific managed object
  func edit<T: NSManagedObject, R>(
    _ object: T,
    _ closure: @escaping (T, _ ctx: NSManagedObjectContext) throws -> R) async throws -> R {
    try await edit(object.getObjectId, closure)
  }

  /// Edits multiple managed objects
  func edit<T: NSManagedObject, R>(
    _ objects: [T],
    _ closure: @escaping ([T], _ ctx: NSManagedObjectContext) throws -> R) async throws -> R {
    let ids = objects.ids
    return try await edit { ctx in
      try closure(ids.objects(ctx), ctx)
    }
  }

  /// Performs a fetch operation
  func fetch<R>(
    _ closure: @escaping (_ ctx: NSManagedObjectContext) throws -> R
  ) async throws -> R {
    let context = createPrivateContext()

    if #available(iOS 15, macOS 12, *) {
      return try await context.perform {
        try closure(context)
      }
    } else {
      return try await withCheckedThrowingContinuation { continuation in
        context.perform {
          do {
            try continuation.resume(returning: closure(context))
          } catch {
            continuation.resume(throwing: error)
          }
        }
      }
    }
  }

  /// Performs a non-throwing fetch operation
  func fetch<R>(
    _ closure: @escaping (_ ctx: NSManagedObjectContext) -> R
  ) async -> R {
    let context = createPrivateContext()

    if #available(iOS 15, macOS 12, *) {
      return await context.perform {
        closure(context)
      }
    } else {
      return await withCheckedContinuation { continuation in
        context.perform {
          continuation.resume(returning: closure(context))
        }
      }
    }
  }
}
