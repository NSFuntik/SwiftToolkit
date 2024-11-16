//
//  Extensions.swift
//  NSSwift
//
//  Created by Dmitry Mikhailov on 29.10.2024.
//
import Core
import Foundation

extension Dictionary where Value == Any? {
  /// Returns a new dictionary without nil and empty values.
  ///
  /// - Returns: A new dictionary with non-empty and non-nil values.
  public func removingEmptyValues() -> [Key: Any] {
    self.removingNilValues().compactMapValues {
      if let value = $0 as? [Any] {
        guard !value.isEmpty else {
          return "Empty"
        }
        if let value = $0 as? [String] {
          return value.joined(separator: ", ")
        }
        return value
      } else if let value = $0 as? JSON {
        return value.dictionary.removingEmptyValues()
      }
      return $0
    }
  }
}

extension Dictionary where Value == Value {
  /// An array of key-value pairs represented as tuples of strings.
  public var keyValuePairs: [(key: String, value: String)] {
    jsonElements.compactMap { ("\($0.key)", "\(String(describing: $0.value))") }
  }

  /// Returns a new dictionary without empty values.
  ///
  /// - Returns: A new dictionary with only non-empty values.
  public func removingEmptyValues() -> [Key: Any] {
    compactMapValues {
      if let value = $0 as? [Any] {
        guard !value.isEmpty else {
          return "Empty"
        }
        if let value = $0 as? [String] {
          return value.joined(separator: ", ")
        }
        return value
      } else if let value = $0 as? [String: Any] {
        return value.jsonElements.removingEmptyValues().keyValuePairs
      }
      return $0
    }
  }

  /// Returns a formatted string representing the dictionary.
  ///
  /// - Returns: A string constructed from non-empty key-value pairs.
  public func print() -> String {
    self.removingEmptyValues()
      .compactMap { " ▶︎ \($0.key) –▷ \($0.value)" }.joined(separator: "\n")
  }
}

extension Dictionary where Value == Any? {}
extension ComparisonResult {
  /// This is a shorthand for `.ordered Ascending`.
  public static var ascending: ComparisonResult {
    .orderedAscending
  }

  /// This is a shorthand for `.orderedDescending`.
  public static var descending: ComparisonResult {
    .orderedDescending
  }
}
