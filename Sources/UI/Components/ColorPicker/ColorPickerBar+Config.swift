import Foundation

#if canImport(UIKit)
import SwiftUI

extension ColorPickerBar {
  /// This type can be used to config a ``ColorPickerBar``.
  public struct Config {
    /// Create a color picker bar configuration.
    ///
    /// - Parameters:
    ///   - addOpacityToPicker: Whether or not to add color picker opacity, by default `true`.
    ///  - addResetButton: Whether or not to add a reset button to the bar, by default `false`.
    ///  - resetButtonValue: The color to apply when tapping the reset button, by default `nil`.
    public init(
      addOpacityToPicker: Bool = true,
      addResetButton: Bool = false,
      resetButtonValue: Color? = nil
    ) {
      self.addOpacityToPicker = addOpacityToPicker
      self.addResetButton = addResetButton
      self.resetButtonValue = resetButtonValue
    }

    /// Whether or not to add color picker opacity.
    public var addOpacityToPicker: Bool

    /// Whether or not to add a reset button to the bar.
    public var addResetButton: Bool

    /// The color to apply when tapping the reset button.
    public var resetButtonValue: Color?

    /// Get the standard configuration.
    public static var standard: Config = .init()
  }
}

extension View {
  /// Apply a ``ColorPickerBar/Config`` style to the view.
  public func colorPickerBarConfig(
    _ config: ColorPickerBar.Config
  ) -> some View {
    self.environment(\.colorPickerBarConfig, config)
  }
}

extension ColorPickerBar.Config {
  fileprivate struct Key: EnvironmentKey {
    public static var defaultValue: ColorPickerBar.Config = .standard
  }
}

extension EnvironmentValues {
  public var colorPickerBarConfig: ColorPickerBar.Config {
    get { self[ColorPickerBar.Config.Key.self] }
    set { self[ColorPickerBar.Config.Key.self] = newValue }
  }
}
#endif
