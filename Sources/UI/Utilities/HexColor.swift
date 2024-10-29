
import SwiftUI
#if canImport(UIKit)
import UIKit.UIColor
#else
import AppKit.NSColor
#endif

// MARK: - ColorError

/// An enumeration representing the different errors that can occur while working with color hex strings.
public enum ColorError: Error, LocalizedError {
  /// Invalid hexadecimal value
  case invalidHexString
  /// Valid hexadecimal long long representation wasn't found
  case invalidScanHexInt64
  /// Invalid hex digit in Integer literal
  case invalidHexDigitInIntegerLiteral
  public var errorDescription: String? {
    switch self {
    case .invalidHexString:
      return "Invalid hexadecimal value"
    case .invalidScanHexInt64:
      return "Valid hexadecimal long long representation wasn't found"
    case .invalidHexDigitInIntegerLiteral:
      return "Invalid hex digit in Integer literal"
    }
  }
}

// MARK: - Platform Specific Color Type

// A typealias that resolves to the appropriate color type depending on the platform.
#if canImport(UIKit)
public typealias PlatformColor = UIColor
#else
public typealias PlatformColor = NSColor
#endif

// MARK: - HexDynamicColor

/// A property wrapper that provides a dynamic color value based on light and dark hex representations.
@propertyWrapper
public struct HexDynamicColor: DynamicProperty, Codable {
  @State private var lightHex: String
  @State private var darkHex: String
  /// Initializes the property wrapper with separate hex values for light and dark appearances.
  /// - Parameters:
  ///   - lightHex: A hex string representing the light appearance color.
  ///   - darkHex: A hex string representing the dark appearance color.
  public init(lightHex: String, darkHex: String) {
    self.lightHex = lightHex
    self.darkHex = darkHex
  }
  
  /// Initializes the property wrapper with separate hex values for light and dark appearances.
  /// - Parameters:
  ///   - light: A hex string representing the light appearance color.
  ///   - dark: A hex string representing the dark appearance color.
  public init(light: String, dark: String) {
    self.lightHex = light
    self.darkHex = dark
  }
  
  /// Initializes the property wrapper with Color objects for light and dark appearances.
  /// - Parameters:
  ///   - light: A Color object representing the light appearance color.
  ///   - dark: A Color object representing the dark appearance color.
  public init(light: Color, dark: Color) {
    self.lightHex = light.toHex()
    self.darkHex = dark.toHex()
  }
  
  /// Initializes the property wrapper with a single hex value for both light and dark appearances.
  /// - Parameter hex: A hex string representing both light and dark appearance colors.
  public init(hex: String) {
    self.lightHex = hex
    self.darkHex = hex
  }
  
  /// Initializes the property wrapper with UIColor or NSColor for light and dark appearances.
  /// - Parameters:
  ///   - light: A PlatformColor object representing the light appearance color.
  ///   - dark: A PlatformColor object representing the dark appearance color.
  public init(light: PlatformColor, dark: PlatformColor) {
    self.lightHex = light.color.toHex()
    self.darkHex = dark.color.toHex()
  }
  
  /// Projects the current value of `HexDynamicColor` as a `Color` object based on environment.
  public var projectedValue: Color {
    get { Color.dynamic(light: lightHex, dark: darkHex) }
    set {
      let newHex = newValue.toHex()
#if os(macOS)
      _ = NSColor(name: nil) { [self] appearance in
        switch appearance.name {
        case .aqua, .vibrantLight, .accessibilityHighContrastAqua, .accessibilityHighContrastVibrantLight:
          self.lightHex = newHex
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
          self.darkHex = newHex
        default:
          self.lightHex = newHex
          self.darkHex = newHex
        }
        return Color(hex: newHex).uiColor
      }
#else
      _ = UIColor { [self] traits in
        switch traits.userInterfaceStyle {
        case .light:
          self.lightHex = newHex
        case .dark:
          self.darkHex = newHex
        case .unspecified:
          self.lightHex = newHex
          self.darkHex = newHex
        @unknown default:
          self.lightHex = newHex
          self.darkHex = newHex
        }
        return Color(hex: newHex).uiColor
      }
#endif
    }
  }
  
  /// Returns `self` when accessed as a wrapped value of type `HexDynamicColor`.
  public var wrappedValue: HexDynamicColor {
    get { self }
    set { self = newValue }
  }
}

// MARK: - Codable Implementation

public extension HexDynamicColor {
  /// Initializes HexDynamicColor from a decoder.
  /// - Parameter decoder: The decoder to read data from.
  /// - Throws: If the data is not in the expected format.
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let hexStrings = try container.decode([String].self)
    guard hexStrings.count == 2 else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Expected two hex color strings.")
    }
    lightHex = hexStrings[0]
    darkHex = hexStrings[1]
  }
  
  /// Encodes the HexDynamicColor into the given encoder.
  /// - Parameter encoder: The encoder to write data to.
  /// - Throws: If an error occurs during encoding.
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode([lightHex, darkHex])
  }
}

// MARK: - HexColor

/// A property wrapper that allows the use of hex string color values.
@propertyWrapper
public struct HexColor: Codable {
  public var wrappedValue: String
  /// Initializes the property wrapper with a hex string color value.
  /// - Parameter wrappedValue: A hex string representing the color.
  public init(wrappedValue: String) {
    self.wrappedValue = wrappedValue
  }
  
  /// Projects the wrapped hex string as a Color object.
  public var projectedValue: Color {
    Color(hex: wrappedValue)
  }
}

// MARK: - Color Extensions

public extension Color {
  /// Converts the Color to a PlatformColor (UIColor or NSColor).
  var uiColor: PlatformColor {
#if canImport(UIKit)
    UIColor(self)
#else
    NSColor(self)
#endif
  }
  
  /// Initializes a Color from a hex string.
  /// - Parameter hex: A hex string representing the color.
  init(hex: String) {
    do {
      var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
      hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
      var rgb: UInt64 = 0
      guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
        throw ColorError.invalidScanHexInt64
      }
      let (a, r, g, b): (UInt64, UInt64, UInt64, UInt64)
      switch hexSanitized.count {
      case 3: // RGB (12-bit)
        (a, r, g, b) = (255, (rgb >> 8) * 17, (rgb >> 4 & 0xF) * 17, (rgb & 0xF) * 17)
      case 6: // RGB (24-bit)
        (a, r, g, b) = (255, rgb >> 16, rgb >> 8 & 0xFF, rgb & 0xFF)
      case 8: // ARGB (32-bit)
        (a, r, g, b) = (rgb >> 24, rgb >> 16 & 0xFF, rgb >> 8 & 0xFF, rgb & 0xFF)
      default:
        throw ColorError.invalidHexDigitInIntegerLiteral
      }
      self.init(
        .displayP3,
        red: Double(r) / 255,
        green: Double(g) / 255,
        blue: Double(b) / 255,
        opacity: Double(a) / 255)
    } catch {
      self.init(white: 0) // Fallback to black color
    }
  }
  
  /// Creates a dynamic color that adapts to light and dark mode.
  /// - Parameters:
  ///   - light: A hex string for the light mode color.
  ///   - dark: A hex string for the dark mode color.
  /// - Returns: A Color that adapts to the light or dark mode.
  static func dynamic(light: String, dark: String) -> Color {
    let lightColor = Color(hex: light)
    let darkColor = Color(hex: dark)
#if os(macOS)
    return NSColor(light: lightColor.uiColor, dark: darkColor.uiColor).color
#else
    return UIColor(light: lightColor.uiColor, dark: darkColor.uiColor).color
#endif
  }
  
  /// Converts the Color to a hex string representation.
  /// - Returns: A hex string representation of the Color.
  func toHex() -> String {
    let color = uiColor
    let components = color.cgColor.components ?? []
    guard components.count >= 3 else { return "000000" }
    let r = Float(components[0])
    let g = Float(components[1])
    let b = Float(components[2])
    let a = components.count >= 4 ? Float(components[3]) : Float(1.0)
    if a != Float(1.0) {
      return String(
        format: "%02lX%02lX%02lX%02lX",
        lroundf(r * 255),
        lroundf(g * 255),
        lroundf(b * 255),
        lroundf(a * 255))
    } else {
      return String(
        format: "%02lX%02lX%02lX",
        lroundf(r * 255),
        lroundf(g * 255),
        lroundf(b * 255))
    }
  }
  
  /// Initializes a Color with separate light and dark mode color closures.
  /// - Parameters:
  ///   - lightModeColor: A closure returning the color for light mode.
  ///   - darkModeColor: A closure returning the color for dark mode.
  init(
    light lightModeColor: @escaping @autoclosure () -> Color,
    dark darkModeColor: @escaping @autoclosure () -> Color) {
#if os(macOS)
      self.init(NSColor(
        light: NSColor(lightModeColor()),
        dark: NSColor(darkModeColor())))
#else
      self.init(UIColor(
        light: UIColor(lightModeColor()),
        dark: UIColor(darkModeColor())))
#endif
    }
}

// MARK: - Platform Color Extensions

#if canImport(UIKit)
public extension UIColor {
  /// Converts the UIColor to a Color object.
  var color: Color { Color(uiColor: self) }
  /// Initializes a UIColor that adapts based on user interface style.
  /// - Parameters:
  ///   - lightModeColor: A closure returning the color for light mode.
  ///   - darkModeColor: A closure returning the color for dark mode.
  convenience init(
    light lightModeColor: @escaping @autoclosure () -> UIColor,
    dark darkModeColor: @escaping @autoclosure () -> UIColor) {
      self.init { traits in
        switch traits.userInterfaceStyle {
        case .light: return lightModeColor()
        case .dark: return darkModeColor()
        @unknown default: return lightModeColor()
        }
      }
    }
}
#else
public extension NSColor {
  /// Converts the NSColor to a Color object.
  var color: Color { Color(nsColor: self) }
  /// Initializes an NSColor that adapts based on appearance.
  /// - Parameters:
  ///   - lightModeColor: A closure returning the color for light mode.
  ///   - darkModeColor: A closure returning the color for dark mode.
  convenience init(
    light lightModeColor: @escaping @autoclosure () -> NSColor,
    dark darkModeColor: @escaping @autoclosure () -> NSColor) {
      self.init(name: nil) { appearance in
        switch appearance.name {
        case .aqua, .vibrantLight, .accessibilityHighContrastAqua, .accessibilityHighContrastVibrantLight:
          return lightModeColor()
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
          return darkModeColor()
        default:
          return lightModeColor()
        }
      }
    }
}
#endif

// MARK: - Preview Provider

#if DEBUG
struct HexColor_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 20) {
      Text("Dynamic Color")
        .foregroundColor(Color.dynamic(light: "#FF0000", dark: "#00FF00"))
      Color(hex: "#FF0000")
        .frame(width: 100, height: 100)
        .cornerRadius(8)
      Color(light: .blue, dark: .red)
        .frame(width: 100, height: 100)
        .cornerRadius(8)
    }
    .padding()
  }
}
#endif
