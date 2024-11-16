import Foundation

#if canImport(UIKit)
import SwiftUI

extension ColorPickerBar {
  /// This type can be used to style a ``ColorPickerBar``.
  public struct Style {
    /// Create a color picker bar configuration.
    ///
    /// - Parameters:
    ///   - animation: The animation to apply when picking color, by default `.default`.
    ///   - spacing: The bar item spacing, by default `10`.
    ///   - colorSize: The size of non-selected colors, by default `20`.
    ///   - selectedColorSize: The size of the selected color, by default `30`.
    ///   - resetButtonImage: The image to use as reset button image, by default `circle.slash`.
    public init(
      animation: Animation = .default,
      spacing: Double = 10.0,
      colorSize: Double = 20.0,
      selectedColorSize: Double = 30.0,
      resetButtonImage: Image = Image(systemName: "xmark.circle")
    ) {
      self.animation = animation
      self.spacing = spacing
      self.colorSize = colorSize
      self.selectedColorSize = selectedColorSize
      self.resetButtonImage = resetButtonImage
    }

    /// The animation to apply when picking colors.
    public var animation: Animation

    /// The bar item spacing.
    public var spacing: Double

    /// The size of non-selected colors.
    public var colorSize: Double

    /// The size of the selected color.
    public var selectedColorSize: Double

    /// The image to use as reset button image
    public var resetButtonImage: Image

    /// Get the standard style.
    public static var standard: Style = .init()
  }
}

extension View {
  /// Apply a ``ColorPickerBar/Style`` style to the view.
  public func colorPickerBarStyle(
    _ style: ColorPickerBar.Style
  ) -> some View {
    self.environment(\.colorPickerBarStyle, style)
  }
}

extension ColorPickerBar.Style {
  fileprivate struct Key: EnvironmentKey {
    public static var defaultValue: ColorPickerBar.Style = .standard
  }
}

extension EnvironmentValues {
  public var colorPickerBarStyle: ColorPickerBar.Style {
    get { self[ColorPickerBar.Style.Key.self] }
    set { self[ColorPickerBar.Style.Key.self] = newValue }
  }
}
#endif
