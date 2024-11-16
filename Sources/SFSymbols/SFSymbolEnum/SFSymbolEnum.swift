import SwiftUI

/// A set of symbols defined by the SF Symbols framework.
extension SFSymbol {
  /// The name of the symbol.
  public var name: String { return self.rawValue }
  /// An image representation of the symbol.
  ///
  /// This property creates an `Image` from the symbol's raw value using the system's image representation.
  @available(iOS 13.4, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
  public var image: Image { return Image(systemName: self.rawValue) }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
extension Image {
  /// Creates an image using a system symbol.
  ///
  /// - Parameter symbol: The `SFSymbol` to create the image from.
  /// This initializer constructs an `Image` using the symbol's name in the SF Symbols framework.
  @available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
  public init(systemName symbol: SFSymbol) {
    self = Image(systemName: symbol.name)
  }

  /// Creates an image using an SF symbol.
  ///
  /// - Parameter symbol: The `SFSymbol` to create the image from.
  /// This initializer constructs an `Image` using the symbol's name in a slightly different manner.
  @available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
  public init(sf symbol: SFSymbol) {
    self = Image(systemName: symbol.name)
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
/// Creates a labeled view with a title and a system image.
///
/// - Parameters:
///   - title: The title of the label.
///   - symbol: The system image represented by an `SFSymbol`.
/// This function returns a `Label` that combines a title with an associated system image.
public func Label(_ title: LocalizedStringKey, systemImage symbol: SFSymbol) -> Label<Text, Image> {
  return Label(title, systemImage: symbol.name)
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
/// Creates a labeled view with a title and an SF symbol.
///
/// - Parameters:
///   - title: The title of the label.
///   - symbol: The symbol to be used as an image for the label.
/// This function returns a `Label` that combines a title with an associated symbol's name as the image.
public func Label(_ title: LocalizedStringKey, symbol: SFSymbol) -> Label<Text, Image> {
  return Label(title, systemImage: symbol.name)
}

// @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
// public extension Label {
//    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
//    init(_ title:LocalizedStringKey, symbol:SFSymbol) {
//        self = Label(title,systemImage:symbol.name)
//    }
// }
//
