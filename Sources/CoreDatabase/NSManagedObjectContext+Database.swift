//
//  NSManagedObjectContext+Database.swift
//  CoreDatabase
//
//  Provides extensions for NSManagedObjectContext with enhanced functionality.

import os.log
import CoreData
import Foundation

public extension NSManagedObjectContext {
  /// Indicates if this is the main view context
  var isViewContext: Bool {
    name == "view"
  }

  /// Executes a fetch request with proper entity configuration
  /// - Parameter request: Fetch request to execute
  /// - Returns: Array of fetched objects
  /// - Throws: Core Data fetch errors
  func execute<T: NSManagedObject>(request: NSFetchRequest<T>) throws -> [T] {
    request.entity = NSEntityDescription.entity(
      forEntityName: String(describing: T.self),
      in: self)!
    return try fetch(request)
  }

  // MARK: - Private Properties

  private static var ignoreMergeKey = 0

  internal var ignoreMerge: Bool {
    get {
      objc_getAssociatedObject(self, &Self.ignoreMergeKey) as? Bool ?? false
    }
    set {
      objc_setAssociatedObject(
        self,
        &Self.ignoreMergeKey,
        newValue,
        .OBJC_ASSOCIATION_RETAIN)
    }
  }

  /// Saves changes in the current context and its parent
  func saveAll() {
    precondition(
      concurrencyType != .mainQueueConcurrencyType,
      "View context cannot be saved")

    guard hasChanges else { return }

    performAndWait {
      do {
        try save()

        if let parent = parent {
          parent.performAndWait {
            guard parent.hasChanges else { return }

            do {
              self.ignoreMerge = true
              try parent.save()
              self.ignoreMerge = false
            } catch {
              os_log(
                "Parent context save failed: %{public}@\n%{public}@",
                log: .default,
                type: .error,
                error.localizedDescription,
                (error as NSError).userInfo)
            }
          }
        }
      } catch {
        os_log(
          "Context save failed: %{public}@\n%{public}@",
          log: .default,
          type: .error,
          error.localizedDescription,
          (error as NSError).userInfo)
      }
    }
  }
}
