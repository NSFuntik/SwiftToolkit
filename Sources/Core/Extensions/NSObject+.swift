//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 27.02.2024.
//
#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif
import AdSupport
import Foundation
import AppTrackingTransparency

/// Executes a given action on the main actor asynchronously.
///
/// This function is useful for ensuring that UI updates are performed on the main thread.
/// - Parameter action: A closure that contains the actions to be performed on the main actor.
public func runOnMainActor(
  _ action: @escaping @MainActor () -> Void
) {
  Task { @MainActor in
    action()
  }
}

/// Executes a given asynchronous action on the main actor.
///
/// This function is useful for ensuring that asynchronous updates to the UI occur on the main thread.
/// - Parameter action: A closure that contains the actions to be performed on the main actor asynchronously.
public func asyncOnMainActor(
  _ action: @escaping @Sendable @MainActor () async -> Void
) {
  Task { @MainActor in
    await action()
  }
}

/// Runs a closure on the main dispatch queue asynchronously.
///
/// This function is useful for performing UI updates or other tasks that need to be executed on the main thread.
/// - Parameter action: A closure that contains the work to be executed on the main queue.
public func runOnMainQueue(
  _ action: @escaping () -> Void
) {
  DispatchQueue.main.async {
    action()
  }
}

/// Unwraps an optional value. If it is `nil`, throws the specified error.
///
/// - Parameters:
///   - optional: The optional value to unwrap.
///   - error: The error to throw if the optional is `nil`.
/// - Throws: The provided error if the optional is `nil`.
/// - Returns: The unwrapped value if it exists.
public func unwrapOrThrow<T>(_ optional: T?, _ error: Error) throws -> T {
  if let value = optional {
    return value
  } else {
    throw error
  }
}

public extension Bool {
  /// Throws an error if the boolean value is `false`.
  ///
  /// - Parameter error: The error to throw if the boolean value is `false`.
  /// - Throws: The provided error if the boolean value is `false`.
  func trueOrThrow(_ error: Error) throws {
    if !self {
      throw error
    }
  }
}

// MARK: - Optional + Equatable

extension Optional: Equatable where Wrapped: Equatable {
  /// Compares two optional values for equality.
  ///
  /// - Parameters:
  ///   - lhs: The first optional value.
  ///   - rhs: The second optional value.
  /// - Returns: A Boolean value indicating whether the optional values are equal.
  public static func == (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none):
      return true
    case let (.some(lhsValue), .some(rhsValue)):
      return lhsValue == rhsValue
    default:
      return false
    }
  }
}

public extension Optional {
  /// Whether or not the value is `nil`.
  var isNil: Bool { return self != nil ? false : true }
  /// Whether or not the value is set and not `nil`.
  var isSet: Bool { !isNil }
}

// MARK: - TypeWrapper

/// Use to wrap primitive Codable
public struct TypeWrapper<T: Codable>: Codable {
  /// Nested Types
  enum CodingKeys: String, CodingKey {
    case object
  }

  /// Properties
  public let object: T
  /// Lifecycle
  /// Initializes a new instance of `TypeWrapper` with the given object.
  ///
  /// - Parameter object: The object to be wrapped.
  public init(object: T) {
    self.object = object
  }
}

// MARK: - File

public struct File {
  // Properties
  public let name: String
  public let url: URL
  public let modificationDate: Date?
  public let size: UInt64?
  /// Lifecycle
  /// Initializes a new `File` instance with the provided properties.
  ///
  /// - Parameters:
  ///   - name: The name of the file.
  ///   - url: The URL of the file.
  ///   - modificationDate: The last modification date of the file, if available.
  ///   - size: The size of the file in bytes, if available.
  public init(
    name: String,
    url: URL,
    modificationDate: Date?,
    size: UInt64?) {
    self.name = name
    self.url = url
    self.modificationDate = modificationDate
    self.size = size
  }
}

public extension File {
  /// Initializes a new `File` instance from a URL.
  ///
  /// This initializer retrieves the file attributes from the given URL. If the attributes cannot be accessed, it returns `nil`.
  /// - Parameter url: The URL of the file.
  init?(url: URL) {
    guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) else {
      return nil
    }
    name = url.lastPathComponent
    self.url = url
    modificationDate = attributes[.modificationDate] as? Date
    size = attributes[.size] as? UInt64
  }
}

#if canImport(UIKit)
  public extension UIView {
    /// Finds the closest view controller that the view is part of.
    ///
    /// This method traverses the responder chain looking for a `UIViewController`.
    /// - Returns: The closest `UIViewController` that contains this view, if found; otherwise, `nil`.
    func closestVC() -> UIViewController? {
      var responder: UIResponder? = self
      while responder != nil {
        if let vc = responder as? UIViewController {
          return vc
        }
        responder = responder?.next
      }
      return nil
    }
  }

  public extension CGFloat {
    /// A computed property that returns the screen width.
    ///
    /// - Returns: The width of the main screen.
    @inline(__always)
    static var screenWidth: CGFloat {
      UIScreen.mainScreen.bounds.width
    }

    /// A computed property that returns the screen height.
    ///
    /// - Returns: The height of the main screen.
    @inline(__always)
    static var screenHeight: CGFloat {
      UIScreen.mainScreen.bounds.height
    }
  }

  /// An extension to remove specific keys and corresponding values from a dictionary.
  ///
  /// - Parameters:
  ///   - keys: An array of keys to be removed from the dictionary.
  /// - Returns: A new dictionary with the specified keys and their values removed.
  public extension Dictionary {
    func removingValues(forKeys keys: [Key]) -> [Key: Value]? {
      var result = self
      for key in keys {
        result.removeValue(forKey: key)
      }
      return result
    }
  }

  public extension UIApplication {
    /// A computed property that provides the key window of the application.
    ///
    /// - Returns: The active key window if available; otherwise, `nil`.
    var keyWindow: UIWindow? {
      UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .first(where: { $0 is UIWindowScene })
        .flatMap { $0 as? UIWindowScene }?.windows
        .first(where: \.isKeyWindow)
    }
  }

  public extension UIApplication {
    /// Ends editing for the application by resigning the first responder.
    ///
    /// - Parameter action: An optional closure to be executed after resigning first responder.
    func endEditing(action: () -> Void = {}) {
      sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
      action()
    }

    /// A computed property that retrieves the active scene for the application.
    ///
    /// - Returns: The active `UIWindowScene` if available; otherwise, `nil`.
    class var activeScene: UIWindowScene? {
      UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .first
        as? UIWindowScene
    }
  }

  public class Utils {
    /// Creates a `UIImage` from the provided data.
    ///
    /// - Parameter data: The data representing the image.
    /// - Returns: A `UIImage` created from the data, or `nil` if the data is invalid.
    public static func image(data: Data) -> UIImage? {
      UIImage(data: data)
    }

    /// Converts a `UIImage` into `Data`.
    ///
    /// - Parameter image: The `UIImage` to be converted.
    /// - Returns: The data representation of the image, or `nil` if the conversion fails.
    public static func data(image: UIImage) -> Data? {
      #if canImport(UIKit)
        return image.jpegData(compressionQuality: 0.9)
      #elseif canImport(AppKit)
        return image.tiffRepresentation
      #else
        return nil
      #endif
    }
  }

  public extension UIScreen {
    /// A computed property that returns the main screen.
    ///
    /// - Returns: The main screen instance.
    @nonobjc
    static var mainScreen: UIScreen { .main }
    /// A computed property that returns the current orientation of the device.
    ///
    /// - Returns: The orientation of the device.
    @nonobjc
    static var orientation: UIDeviceOrientation {
      let point = UIScreen.mainScreen.coordinateSpace.convert(CGPoint.zero, to: UIScreen.mainScreen.fixedCoordinateSpace)
      if point == CGPoint.zero {
        return .portrait
      } else if point.x != 0, point.y != 0 {
        return .portraitUpsideDown
      } else if point.x == 0, point.y != 0 {
        return .landscapeRight // .landscapeLeft
      } else if point.x != 0, point.y == 0 {
        return .landscapeLeft // .landscapeRight
      } else {
        return .unknown
      }
    }
  }
#endif
/// Maps the keys of a dictionary using a transformation closure.
///
/// - Parameter transform: A closure that takes a key as its parameter and returns a transformed key.
/// - Returns: A new dictionary with the transformed keys and original values.
extension Dictionary {
  func mapKeys<TransformedKey: Hashable>(_ transform: (Key) -> TransformedKey) -> [TransformedKey: Value] {
    .init(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
  }

  /// Removes values for the specified keys from the dictionary.
  ///
  /// - Parameter keys: An array of keys whose corresponding values are to be removed.
  /// - Returns: An array of optional values that were removed.
  @discardableResult
  mutating func removeValues(forKeys keys: [Key]) -> [Value?] {
    keys.map { removeValue(forKey: $0) }
  }

  /// Returns a new dictionary with the values corresponding to the specified keys removed.
  ///
  /// - Parameter keys: An array of keys whose corresponding values are to be removed.
  /// - Returns: A new dictionary with the specified keys and their values removed.
  func removingValues(forKeys keys: [Key]) -> Self {
    var result = self
    result.removeValues(forKeys: keys)
    return result
  }

  /// Returns a new dictionary with the specified keys removed.
  ///
  /// - Parameter keys: An array of keys to remove from the dictionary.
  /// - Returns: A new dictionary with the specified keys removed.
  func removingKeys(_ keys: [Key]) -> Self {
    var result = self
    keys.forEach { result.removeValue(forKey: $0) }
    return result
  }
}

/// An extension of `Dictionary` where the key is a `String`.
extension Dictionary where Key == String {
  /// Returns a new dictionary with the specified string keys removed.
  ///
  /// - Parameter keys: An array of string keys to remove from the dictionary.
  /// - Returns: A new dictionary with the specified keys removed.
  func removingKeys(_ keys: [String]) -> Self {
    var result = self
    keys.forEach { result.removeValue(forKey: $0) }
    return result
  }

  /// Returns a new dictionary with the specified string keys removed.
  ///
  /// - Parameter keys: Varadic list of string keys to remove from the dictionary.
  /// - Returns: A new dictionary with the specified keys removed.
  func removingKeys(_ keys: String...) -> Self {
    var result = self
    keys.forEach { result.removeValue(forKey: $0) }
    return result
  }
}
