//
//  for.swift
//  NSSwift
//
//  Created by Dmitry Mikhailov on 29.10.2024.
//


// MARK: - Set + StorageCodable

/// Extends the `Set` type to conform to `RawRepresentable` when its element is a `String`.
extension Set: @retroactive RawRepresentable where Set.Element == String {}

// MARK: - Set + StorageCodable

/// Extends `Set<String>` to conform to the `StorageCodable` protocol for encoding and decoding.
extension Set<String>: StorageCodable {
  /// The raw string representation of the set, joined by " && ".
  public var rawValue: String {
    joined(separator: " && ")
  }

  /// Initializes a new `Set` with the raw string representation.
  ///
  /// - Parameter rawValue: A string that represents the set of strings.
  public init?(rawValue: String) {
    self.init(rawValue.components(separatedBy: " && "))
  }

  /// Encodes the set to a single value container.
  ///
  /// - Parameter encoder: The encoder to write data to.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }

  /// Initializes a new set from a decoder.
  ///
  /// - Parameter decoder: The decoder to read data from.
  /// - Throws: An error if decoding fails.
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Set(rawValue.components(separatedBy: " && "))
  }
}