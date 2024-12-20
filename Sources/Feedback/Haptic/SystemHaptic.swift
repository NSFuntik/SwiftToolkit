import SwiftUI

#if os(iOS)
extension AnyFeedback {
  /// Specifies haptic feedback provided by the system
  /// - Parameter style: The style of the haptic feedback
  public static func haptic(_ style: HapticStyle) -> Self {
    .init(SystemHaptic(style: style))
  }
}

extension HapticStyle {
  /// Used to give user feedback when a selection changes
  public static var selection: Self { .init(style: .selection) }

  /// Used to give user feedback when a notification is displayed
  public static var notification: Self { .init(style: .notification(.success)) }

  /// Used to give user feedback when an impact between UI elements occurs
  public static var impact: Self { .init(style: .impact(.medium, intensity: 1)) }

  public static func notification(_ style: NotificationStyle) -> Self {
    .init(style: .notification(style))
  }

  public static func impact(_ style: ImpactStyle, intensity: Double = 1) -> Self {
    .init(style: .impact(style, intensity: intensity))
  }
}

struct SystemHaptic: Feedback {
  var style: HapticStyle

  public func perform() async {
    switch style.style {
    case .selection:
      await UISelectionFeedbackGenerator()
        .selectionChanged()
    case let .notification(style):
      await UINotificationFeedbackGenerator()
        .notificationOccurred(style.type)
    case .error:
      await UINotificationFeedbackGenerator()
        .notificationOccurred(.error)
    case let .impact(style, intensity):
      await UIImpactFeedbackGenerator(style: style.style)
        .impactOccurred(intensity: max(0, min(1, intensity)))
    }
  }
}

/// The type of notification that a notification feedback generator object generates
public enum NotificationStyle: String {
  /// A notification feedback type that indicates a task has completed successfully.
  case success
  /// A notification feedback type that indicates a task has produced a warning.
  case warning
  /// A notification feedback type that indicates a task has failed.
  case error

  #if os(iOS)
  var type: UINotificationFeedbackGenerator.FeedbackType {
    switch self {
    case .success: return .success
    case .warning: return .warning
    case .error: return .error
    }
  }
  #endif
}

public enum ImpactStyle: String {
  /// A collision between small, light user interface elements.
  case light
  /// A collision between user interface elements that are soft, exhibiting a large amount of compression or elasticity.
  case soft
  /// A collision between moderately sized user interface elements.
  case medium
  /// A collision between large, heavy user interface elements.
  case heavy
  /// A collision between user interface elements that are rigid, exhibiting a small amount of compression or elasticity.
  case rigid

  #if os(iOS)
  var style: UIImpactFeedbackGenerator.FeedbackStyle {
    switch self {
    case .light: return .light
    case .soft: return .soft
    case .medium: return .medium
    case .heavy: return .heavy
    case .rigid: return .rigid
    }
  }
  #endif
}

/// The style of the system haptic
public struct HapticStyle: CustomStringConvertible {
  let style: Style
}

extension HapticStyle {
  public var description: String {
    style.description
  }

  enum Style: CustomStringConvertible {
    case selection
    case notification(_ style: NotificationStyle)
    case error
    case impact(_ style: ImpactStyle, intensity: Double = 1)

    var description: String {
      switch self {
      case let .impact(style, intensity): return "\(style) (\(intensity))"
      case .error: return "error"
      case let .notification(style): return "\(style)"
      case .selection: return "selection"
      }
    }
  }
}
#endif
