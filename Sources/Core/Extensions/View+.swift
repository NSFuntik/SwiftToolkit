// swift-format-ignore-file
import SwiftUI

public extension Font {
  /// Creates a system font with specified characteristics.
  /// - Parameters:
  ///   - style: The text style to be used. Defaults to `.body`.
  ///   - design: The font design to be applied. Defaults to `.default`.
  ///   - weight: The weight of the font. Defaults to `.regular`.
  /// - Returns: A system font configured according to the specified parameters.
  @available(iOS 15.0, *)
  static func system(
    _ style: Font.TextStyle = .body,
    _ design: Font.Design = .default,
    _ weight: Font.Weight = .regular) -> Font {
    if #available(iOS 16.0, *) {
      if #available(macOS 13.0, *) {
        SwiftUI.Font.system(style, design: design, weight: weight)
      } else {
        // Fallback on earlier versions
        SwiftUI.Font.system(style, design: design).weight(weight)
      }
    } else {
      SwiftUI.Font.system(style, design: design).weight(weight)
    }
  }

  /// Creates a system font with specified text style and weight.
  /// - Parameters:
  ///   - style: The text style to be used. Defaults to `.body`.
  ///   - weight: The weight of the font. Defaults to `.regular`.
  /// - Returns: A system font configured according to the specified parameters.
  static func system(
    _ style: Font.TextStyle = .body,
    _ weight: Font.Weight = .regular) -> Font {
    if #available(iOS 16.0, *) {
      if #available(macOS 13.0, *) {
        SwiftUI.Font.system(style, design: .default, weight: weight)
      } else {
        // Fallback on earlier versions
        SwiftUI.Font.system(style, design: .default).weight(weight)
      }
    } else {
      .system(style, design: .default).weight(weight)
    }
  }
}

public extension View {
  /// Embeds the current view inside a `NavigationView`.
  /// - Returns: A `NavigationView` containing the current view.
  func embedInNavigation() -> some View {
    NavigationView { self }
  }

  /// Erases the type of the current view to `AnyView`.
  /// - Returns: An `AnyView` wrapping the current view.
  func eraseToAnyView() -> AnyView {
    AnyView(self)
  }

  /// Conditionally transforms the view based on a Boolean condition.
  /// - Parameters:
  ///   - condition: A closure returning a Boolean value to determine whether to apply the transformation.
  ///   - transform: A closure that transforms the original view if the condition is true.
  /// - Returns: Either the transformed view or the original view based on the condition.
  @ViewBuilder func `if`(
    _ condition: @autoclosure () -> Bool,
    _ transform: (Self) -> some View)
  -> some View {
    if condition() {
      transform(self)
    } else {
      self
    }
  }

  /// Conditionally transforms the view with an else case based on a Boolean condition.
  /// - Parameters:
  ///   - condition: A closure returning a Boolean value to determine which transformation to apply.
  ///   - transform: A closure that transforms the original view if the condition is true.
  ///   - else _transform: A closure that provides an alternative transformation if the condition is false.
  /// - Returns: The transformed view based on the condition, for true or false.
  @ViewBuilder
  func `if`(
    _ condition: @autoclosure () -> Bool,
    _ transform: (Self) -> some View,
    else _transform: (Self) -> some View) -> some View {
    if condition() {
      transform(self)
    } else {
      _transform(self)
    }
  }

  /// Conditionally transforms the view if the optional value is non-nil.
  /// - Parameters:
  ///   - value: An optional value that determines whether the transformation should be applied.
  ///   - transform: A closure taking the original view and the unwrapped value, returning modified content.
  /// - Returns: If the optional value is non-nil, returns the transformed content; otherwise, returns the original view.
  @ViewBuilder
  func ifLet<T, Content: View>(
    _ value: T?,
    transform: (Self, T) -> Content) -> some View {
    if let value {
      transform(self, value)
    } else {
      self
    }
  }

  /// Conditionally transforms the view based on an optional value with an else case.
  /// - Parameters:
  ///   - value: An optional value that determines whether the transformation should be applied.
  ///   - transform: A closure taking the original view and the unwrapped value, returning modified content.
  ///   - else _transform: A closure providing an alternative transformation if the value is nil.
  /// - Returns: The transformed content based on the optional value, for both non-nil and nil cases.
  @ViewBuilder
  func ifLet<T, Content: View>(
    _ value: T?,
    transform: (Self, T) -> Content,
    else _transform: (Self) -> Content) -> some View {
    if let value {
      transform(self, value)
    } else {
      _transform(self)
    }
  }

  /// Sets the view's frame to a square size.
  /// - Parameter box: The size of the square frame.
  /// - Returns: A view with a square frame of the specified size.
  @inlinable
  func frame(box: CGFloat) -> some View { frame(width: box, height: box, alignment: .center) }
  /// Sets the view's frame to a specified size.
  /// - Parameter size: The size of the frame.
  /// - Returns: A view with a frame of the specified size.
  @inlinable
  func frame(
    _ size: CGSize
  ) -> some View {
    frame(
      width: size.width,
      height: size.height,
      alignment: .center)
  }

  /// Applies padding to the view with specified vertical and horizontal amounts.
  /// - Parameters:
  ///   - vertical: The vertical padding amount.
  ///   - horizontal: The horizontal padding amount.
  /// - Returns: A view with the applied padding.
  @inlinable
  func padding(
    _ vertical: CGFloat,
    _ horizontal: CGFloat) -> some View {
    padding(
      EdgeInsets(
        top: vertical,
        leading: horizontal,
        bottom: vertical,
        trailing: horizontal)
    )
  }

  /// Applies padding to the view with specified vertical, leading, and trailing amounts.
  /// - Parameters:
  ///   - vertical: The vertical padding amount.
  ///   - leading: The leading padding amount.
  ///   - trailing: The trailing padding amount.
  /// - Returns: A view with the applied padding.
  @inlinable
  func padding(
    vertical: CGFloat,
    leading: CGFloat = 0,
    trailing: CGFloat = 0) -> some View {
    padding(
      EdgeInsets(
        top: vertical,
        leading: leading,
        bottom: vertical,
        trailing: trailing)
    )
  }

  /// Applies padding to the view with specified top, bottom, and horizontal amounts.
  /// - Parameters:
  ///   - top: The top padding amount.
  ///   - bottom: The bottom padding amount.
  ///   - horizontal: The horizontal padding amount.
  /// - Returns: A view with the applied padding.
  @inlinable
  func padding(
    top: CGFloat = 0,
    bottom: CGFloat = 0,
    horizontal: CGFloat) -> some View {
    padding(
      EdgeInsets(
        top: top,
        leading: horizontal,
        bottom: bottom,
        trailing: horizontal)
    )
  }

  /// Applies padding to the view with specified top, bottom, leading, and trailing amounts.
  /// - Parameters:
  ///   - top: The top padding amount.
  ///   - bottom: The bottom padding amount.
  ///   - leading: The leading padding amount.
  ///   - trailing: The trailing padding amount.
  /// - Returns: A view with the applied padding.
  @inlinable
  func padding(
    top: CGFloat,
    bottom: CGFloat = 0,
    leading: CGFloat = 0,
    trailing: CGFloat = 0) -> some View {
    padding(
      EdgeInsets(
        top: top,
        leading: leading,
        bottom: bottom,
        trailing: trailing)
    )
  }

  /// Conditionally hides the view based on a Boolean value.
  /// - Parameter isHidden: A Boolean that determines if the view should be hidden.
  /// - Returns: Either the hidden view with animation or the original view.
  @ViewBuilder
  func isHidden(_ isHidden: Bool) -> some View {
    if isHidden {
      self.hidden().animation(.interpolatingSpring, value: isHidden)
    } else {
      self
    }
  }

  /// Creates spacing around the view within a horizontal stack.
  /// - Returns: A horizontal stack containing the view with a spacer adjacent to it.
  @inlinable
  func spacing() -> some View { HStack { self; Spacer() } }
}

#if canImport(UIKit)
  public extension View {
    /// Adjusts the visibility of the toolbar based on the specified condition.
    /// - Parameter visibility: The desired visibility of the toolbar.
    /// - Returns: A view with the toolbar visibility adjusted.
    @ViewBuilder func toolbar(_ visibility: Visibility) -> some View {
      if #available(iOS 16.0, *) {
        self.toolbar(visibility, for: .navigationBar)
      } else {
        navigationBarHidden(visibility != .visible)
      }
    }
  }

  /// A `UIColor` extension that provides functionality for generating adaptive colors based on a seed string.
  /// - Author: Your Name
  public extension UIColor {
    /// Generates a light color based on a seed string.
    /// - Parameters:
    ///   - seed: A string used as a seed for random color generation.
    /// - Returns: A `UIColor` object representing the generated color.
    private class func lightColor(withSeed seed: String) -> UIColor {
      // Generate a light color
      srand48(seed.hash)
      let hue = CGFloat(drand48())
      let saturation = CGFloat(0.5)
      let brightness = CGFloat(1.0 - 0.25 * drand48())
      return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }

    /// Generates a dark color based on a seed string.
    /// - Parameters:
    ///   - seed: A string used as a seed for random color generation.
    /// - Returns: A `UIColor` object representing the generated color.
    private class func darkColor(withSeed seed: String) -> UIColor {
      // Generate a dark color
      srand48(seed.hash)
      let hue = CGFloat(drand48())
      let saturation = CGFloat(0.5)
      let brightness = CGFloat(0.3 + 0.25 * drand48())
      return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }

    /// Generates an adaptive color that adapts to the user interface style.
    /// - Parameters:
    ///   - seed: A string used as a seed for random color generation.
    /// - Returns: A `UIColor` object representing the generated adaptive color.
    class func adaptiveColor(withSeed seed: String) -> UIColor {
      let light = lightColor(withSeed: seed)
      let dark = darkColor(withSeed: seed)
      return UIColor { traitCollection -> UIColor in
        if traitCollection.userInterfaceStyle == .dark {
          return dark
        }
        return light
      }
    }
  }

  public extension Color {
    /// Creates an adaptive color using a seed string and returns it as a Color.
    /// - Parameters:
    ///   - seed: A string used as a seed for random color generation.
    /// - Returns: A `Color` object representing the generated adaptive color.
    @inlinable
    static func adaptiveColor(withSeed seed: String) -> Color {
      Color(UIColor.adaptiveColor(withSeed: seed))
    }

    /// Initializes a `Color` object that adapts to the seed string.
    /// - Parameter adaptWithSeed: A string used as a seed for random color generation.
    init(adaptWithSeed: String) {
      self.init(UIColor.adaptiveColor(withSeed: adaptWithSeed))
    }
  }

  public extension View {
    /// Applies a highlight effect to the view based on the iOS version.
    /// - Returns: A view with a highlight effect applied.
    @available(iOS 15, *)
    func highlightEffect() -> some View {
      Group {
        if #available(iOS 17, *) {
          self.hoverEffect(.highlight, isEnabled: true)
        } else {
          self.contentShape(RoundedRectangle(cornerRadius: 13, style: .continuous).inset(by: -20))
            .hoverEffect(.highlight)
        }
      }
    }

    /// Ignores the keyboard when the view is in use.
    /// - Returns: A view with keyboard interaction ignored.
    @ViewBuilder
    func ignoreKeyboard() -> some View {
      if #available(iOS 14, *) {
        ignoresSafeArea(.keyboard, edges: .all)
      } else {
        self
      }
    }

    /// Applies a vibrant foreground style based on the iOS version.
    /// - Parameter thick: A Boolean that determines if a thick or thin material should be applied. Defaults to false.
    /// - Returns: A view with a vibrant foreground style.
    @ViewBuilder
    func vibrantForeground(thick: Bool = false) -> some View {
      if #available(iOS 15, *) {
        foregroundStyle(thick ? .thickMaterial : .thin)
      } else {
        foregroundColor(Color(.systemBackground))
      }
    }
  }
#endif
