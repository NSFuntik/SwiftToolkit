import SwiftUI

#if canImport(CoreHaptics)
import CoreHaptics
#endif

// MARK: - Feedback

/// Represents a feedback type
public protocol Feedback {
  func perform() async
}

#if os(iOS)
/// Returns the result of recomputing the view's body with the provided animation.
/// - Parameters:
///   - feedback: The feedback to perform when the body is called
///   - body: The content of this value will be called alongside the feedback
public func withFeedback<Result>(
  _ feedback: AnyFeedback = .haptic(.selection),
  _ body: () throws -> Result
) rethrows
  -> Result
{
  Task { await feedback.perform() }
  return try body()
}
#else
/// Returns the result of recomputing the view's body with the provided animation.
/// - Parameters:
///   - feedback: The feedback to perform when the body is called
///   - body: The content of this value will be called alongside the feedback
public func withFeedback<Result>(
  _ feedback: AnyFeedback = .haptic(.haptic(intensity: 0.5, sharpness: 0.5)),
  _ body: () throws -> Result
) rethrows -> Result {
  Task { await feedback.perform() }
  return try body()
}
#endif

extension View {
  /// Attaches some feedback to this view when the specified value changes
  /// - Parameters:
  ///   - feedback: The feedback to perform when the value changes
  ///   - value: The value to observe for changes
  public func feedback<V>(_ feedback: AnyFeedback, value: V) -> some View where V: Equatable {
    modifier(FeedbackModifier(feedback: feedback, value: value))
  }
}

extension ModifiedContent: @unchecked Sendable {}

// MARK: - ModifiedContent + Feedback

extension ModifiedContent: Feedback where Content: Feedback, Modifier: Feedback {
  /// Performs the specified feedback and any associated feedback (via combined)
  public func perform() async {
    async let c: Void = content.perform()
    async let m: Void = modifier.perform()
    _ = await (c, m)
  }
}

extension Feedback {
  /// Combines this feedback with another
  /// - Parameter feedback: The feedback to combine with this feedback
  /// - Returns: The combined feedback
  public func combined(with feedback: AnyFeedback) -> AnyFeedback {
    AnyFeedback(ModifiedContent(content: self, modifier: feedback))
  }
}

// MARK: - FeedbackModifier

struct FeedbackModifier<V: Equatable>: ViewModifier {
  let feedback: any Feedback
  let value: V

  func body(content: Content) -> some View {
    if #available(iOS 14, tvOS 14, macOS 11, watchOS 7, *) {
      content
        .onChange(of: value) { _ in
          Task { await feedback.perform() }
        }
    } else {
      content
        .onChange(of: value) { _ in
          Task { await feedback.perform() }
        }
    }
  }
}
