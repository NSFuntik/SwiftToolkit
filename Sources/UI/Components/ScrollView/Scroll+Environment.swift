
import SwiftUI

@available(iOS, deprecated: 16)
@available(tvOS, deprecated: 16)
@available(macOS, deprecated: 13)
@available(watchOS, deprecated: 9)
extension EnvironmentValues {
  /// The visiblity to apply to scroll indicators of any
  /// vertically scrollable content.
  public var verticalScrollIndicatorVisibility: ScrollIndicatorVisibility {
    get { self[BackportVerticalIndicatorKey.self] }
    set { self[BackportVerticalIndicatorKey.self] = newValue }
  }

  /// The visibility to apply to scroll indicators of any
  /// horizontally scrollable content.
  public var horizontalScrollIndicatorVisibility: ScrollIndicatorVisibility {
    get { self[BackportHorizontalIndicatorKey.self] }
    set { self[BackportHorizontalIndicatorKey.self] = newValue }
  }

  /// The way that scrollable content interacts with the software keyboard.
  ///
  public var scrollDismissesKeyboardMode: ScrollDismissesKeyboardMode {
    get { self[BackportKeyboardDismissKey.self] }
    set { self[BackportKeyboardDismissKey.self] = newValue }
  }

  /// A Boolean value that indicates whether any scroll views associated
  /// with this environment allow scrolling to occur.
  ///
  /// The default value is `true`. Use the ``View.scrollDisabled(_:)``
  /// modifier to configure this property.
  public var isScrollEnabled: Bool {
    get { self[BackportScrollEnabledKey.self] }
    set { self[BackportScrollEnabledKey.self] = newValue }
  }
}

// MARK: - BackportVerticalIndicatorKey

private struct BackportVerticalIndicatorKey: EnvironmentKey {
  static var defaultValue: ScrollIndicatorVisibility = .automatic
}

// MARK: - BackportHorizontalIndicatorKey

private struct BackportHorizontalIndicatorKey: EnvironmentKey {
  static var defaultValue: ScrollIndicatorVisibility = .automatic
}

// MARK: - BackportKeyboardDismissKey

private struct BackportKeyboardDismissKey: EnvironmentKey {
  static var defaultValue: ScrollDismissesKeyboardMode = .automatic
}

// MARK: - BackportScrollEnabledKey

private struct BackportScrollEnabledKey: EnvironmentKey {
  static var defaultValue: Bool = true
}
