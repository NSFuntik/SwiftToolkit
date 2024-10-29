import SwiftUI
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension Binding {
  /// This type makes it possible to use optional bindings with a
  /// range of native SwiftUI controls.
  ///
  @inlinable
  func unwrapped<T>(_ defaultValue: T) -> Binding<T> where Value == T? {
    Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
  }
}

