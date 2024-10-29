import SwiftUI
import Combine

public protocol Observable: ObservableObject {}
public extension View {
  /// Places a perceptible object in the view’s environment.
  ///
  /// A backport of SwiftUI's `View.environment` that takes an observable object.
  ///
  /// - Parameter object: The object to set for this object's type in the environment, or `nil` to
  ///   clear an object of this type from the environment.
  /// - Returns: A view that has the specified object in its environment.
  func environment<T: AnyObject & Observable>(_ object: T?) -> some View {
    self.environment(\.[\T.self], object)
  }
}

// MARK: - PerceptibleKey

/// A struct that conforms to `EnvironmentKey`, used to store a perceptible object.
private struct PerceptibleKey<T: Observable>: EnvironmentKey {
  /// The default value for the perceptible key is `nil`.
  static var defaultValue: T? { nil }
}

private extension EnvironmentValues {
  /// A subscript to get or set an optional observable object in the environment using a key path.
  ///
  /// - Parameter _: The key path for the observable object type.
  subscript<T: Observable>(_: KeyPath<T, T>) -> T? {
    get { self[PerceptibleKey<T>.self] }
    set { self[PerceptibleKey<T>.self] = newValue }
  }

  /// A subscript to get or set a non-optional observable object in the environment using a key path.
  ///
  /// - Parameter unwrap: The key path for the observable object type.
  /// - Throws: A fatal error if the object is not found in the environment.
  subscript<T: Observable>(unwrap _: KeyPath<T, T>) -> T {
    get {
      guard let object = self[\T.self] else {
        fatalError(
          """
          No perceptible object of type \(T.self) found. A View.environment(_:) for \(T.self) may \
          be missing as an ancestor of this view.
          """
        )
      }
      return object
    }
    set { self[\T.self] = newValue }
  }
}

public extension Task {
  /// Waits for all tasks in the given array to complete and returns their results.
  ///
  /// This method creates a throwing task group where each task's result is collected and returned.
  ///
  /// - Parameter tasks: An array of tasks that produce results of type `T` or an error.
  /// - Throws: An error if any of the tasks throw an error.
  /// - Returns: An array of results collected from the completed tasks.
  func whenAll<T>(tasks: [Task<T, Error>]) async throws -> [T] {
    try await withThrowingTaskGroup(of: [T].self, body: { group in
      for task in tasks {
        group.addTask {
          try [await task.value]
        }
      }
      return try await group.reduce([], +)
    })
  }
}
