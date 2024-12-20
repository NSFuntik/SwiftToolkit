import SwiftUI

extension AnyFeedback {
  /// Defines a delay before the next feedback is performed
  /// - Parameter delay: The duration of the delay
  public func delay(_ delay: Double) -> Self {
    .init(DelayedFeedback(duration: delay, haptic: self))
  }
}

// MARK: - DelayedFeedback

private struct DelayedFeedback: Feedback {
  let duration: Double
  let haptic: any Feedback

  @MainActor
  public func perform() async {
    do {
      try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
      await haptic.perform()
    } catch {}
  }
}
