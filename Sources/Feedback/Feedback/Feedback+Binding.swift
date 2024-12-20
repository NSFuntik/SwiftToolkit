import SwiftUI

extension Binding {
  /// Specifies the feedback to perform when the binding value changes.
  /// - Parameter feedback: Feedback performed when the binding value changes.
  ///
  /// - Returns: A new binding.
  public func feedback(_ feedback: AnyFeedback) -> Self {
    Binding(
      get: { wrappedValue },
      set: { newValue in
        withFeedback(feedback) { wrappedValue = newValue }
      }
    )
  }
}

extension Binding where Value: BinaryFloatingPoint {
  /// Specifies the feedback to perform when the binding value changes.
  /// - Parameter feedback: Feedback performed when the binding value changes.
  /// - Parameter step: The step required to trigger a binding change
  ///
  /// - Returns: A new binding.
  public func feedback(_ feedback: AnyFeedback, step: Value) -> Self {
    Binding(
      get: { wrappedValue },
      set: { newValue in
        let oldValue = round(wrappedValue / step) * step
        let stepValue = round(newValue / step) * step

        if oldValue != stepValue {
          withFeedback(feedback) { wrappedValue = newValue }
        } else {
          wrappedValue = newValue
        }
      }
    )
  }
}

extension Binding where Value: BinaryInteger {
  /// Specifies the feedback to perform when the binding value changes.
  /// - Parameter feedback: Feedback performed when the binding value changes.
  /// - Parameter step: The step required to trigger a binding change
  ///
  /// - Returns: A new binding.
  public func feedback(_ feedback: AnyFeedback, step: Value) -> Self {
    Binding(
      get: { wrappedValue },
      set: { newValue in
        let oldValue = wrappedValue / step * step
        let stepValue = newValue / step * step

        if oldValue != stepValue {
          withFeedback(feedback) { wrappedValue = newValue }
        } else {
          wrappedValue = newValue
        }
      }
    )
  }
}
