//
//  Extensions.swift
//  NSSwift
//
//  Created by Dmitry Mikhailov on 29.10.2024.
//
import Core
import Foundation

public extension Dictionary where Value == Any? {
  /// Returns a new dictionary without nil and empty values.
  ///
  /// - Returns: A new dictionary with non-empty and non-nil values.
  func removingEmptyValues() -> [Key: Any] {
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

public extension Dictionary where Value == Value {
  /// An array of key-value pairs represented as tuples of strings.
  var keyValuePairs: [(key: String, value: String)] {
    jsonElements.compactMap { ("\($0.key)", "\(String(describing: $0.value))") }
  }

  /// Returns a new dictionary without empty values.
  ///
  /// - Returns: A new dictionary with only non-empty values.
  func removingEmptyValues() -> [Key: Any] {
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
  func print() -> String {
    self.removingEmptyValues()
      .compactMap { " ▶︎ \($0.key) –▷ \($0.value)" }.joined(separator: "\n")
  }
}

public extension Dictionary where Value == Any? {}
public extension ComparisonResult {
  /// This is a shorthand for `.ordered Ascending`.
  static var ascending: ComparisonResult {
    .orderedAscending
  }

  /// This is a shorthand for `.orderedDescending`.
  static var descending: ComparisonResult {
    .orderedDescending
  }
}
