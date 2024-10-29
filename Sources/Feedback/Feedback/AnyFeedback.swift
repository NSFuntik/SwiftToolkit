import SwiftUI

/// A type-erased Feedback
public struct AnyFeedback: Feedback {
  private var haptic: Feedback

  /// The feedback to type-erase
  public init(_ haptic: Feedback) {
    self.haptic = haptic
  }

  /// Asks the type-erased feedback to perform
  @MainActor
  public func perform() async {
    await haptic.perform()
  }

  @MainActor
  private var task: Task<Void, Never> {
    return Task<Void, Never> {
      if Task.isCancelled {
        debugPrint("􀪅 New message sound cancelled")

      } else {
        debugPrint("􀐣 New Message playing ")
        await self.delay(0.666).perform()
      }
    }
  }

  @MainActor
  public func play() async {
    self.task.cancel()

    _ = self.task
  }
}
