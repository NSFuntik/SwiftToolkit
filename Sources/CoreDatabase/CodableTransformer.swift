//
//  CodableTransformer.swift
//  CoreDatabase
//
//  Provides a robust ValueTransformer for encoding and decoding complex Codable objects.

import os.log
import Foundation

// MARK: - CodableTransformer

/// A flexible ValueTransformer supporting complex Codable transformations
public final class CodableTransformer: ValueTransformer {
  /// Represents a type-safe, recursive codable value with comprehensive transformation capabilities
  private indirect enum Value: Codable {
    case string(String)
    case number(Data)
    case codableObject(base64: String, name: String)
    case array([Value])
    case dictionary([String: Value])

    /// Safely initialize a Value from various input types
    /// - Parameter value: The value to transform
    /// - Returns: A transformed Value or nil if transformation is not possible
    init?(value: Any) {
      switch value {
      case let stringValue as String:
        self = .string(stringValue)
      case let numberValue as NSNumber:
        guard let data = try? JSONSerialization.data(withJSONObject: [numberValue]) else {
          return nil
        }
        self = .number(data)
      case let numberArray as [NSNumber]:
        self = .array(numberArray.compactMap { Value(value: $0) })
      case let stringArray as [String]:
        self = .array(stringArray.compactMap { Value(value: $0) })
      case let encodableArray as [Encodable]:
        self = .array(encodableArray.compactMap { Value(value: $0) })
      case let encodableObject as (AnyObject & Encodable):
        guard let base64Data = try? encodableObject.toData().base64EncodedString() else {
          return nil
        }
        self = .codableObject(
          base64: base64Data,
          name: NSStringFromClass(type(of: encodableObject)))
      case let dictionary as [String: Any]:
        self = .dictionary(dictionary.reduce(into: [:]) { result, item in
          guard let value = Value(value: item.value) else { return }
          result[item.key] = value
        })
      default:
        return nil
      }
    }

    /// Convert the Value back to its original object representation
    /// - Returns: The decoded object
    /// - Throws: Decoding errors if transformation fails
    func object() throws -> Any {
      switch self {
      case let .string(string):
        return string
      case let .number(number):
        guard let result = try? JSONSerialization.jsonObject(with: number) as? NSNumber else {
          throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid number data"))
        }
        return result
      case let .array(array):
        return array.compactMap { try? $0.object() }
      case let .dictionary(dict):
        return dict.reduce(into: [:]) { result, item in
          guard let value = try? item.value.object() else { return }
          result[item.key] = value
        }
      case let .codableObject(base64, className):
        guard let data = Data(base64Encoded: base64),
              let classObject = NSClassFromString(className) as? Decodable.Type else {
          throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid codable object"))
        }
        return try classObject.decode(data)
      }
    }
  }

  /// Returns the class type for transformed values
  override public class func transformedValueClass() -> AnyClass {
    NSData.self
  }

  /// Performs reverse transformation from Data to original value
  override public func reverseTransformedValue(_ value: Any?) -> Any? {
    guard let data = value as? Data else { return nil }
    return try? Value.decode(data).object()
  }

  /// Indicates that reverse transformation is supported
  override public class func allowsReverseTransformation() -> Bool {
    true
  }

  /// Transforms a value into its Data representation
  override public func transformedValue(_ value: Any?) -> Any? {
    guard let value = value,
          let encodingValue = Value(value: value) else {
      return nil
    }

    do {
      return try encodingValue.toData()
    } catch {
      os_log("Transformation failed: %{public}@", log: .default, type: .error, error.localizedDescription)
      return nil
    }
  }
}

// MARK: - Private Extensions

private extension Encodable {
  /// Converts an Encodable object to Data with ISO8601 date encoding
  /// - Parameter encoder: Custom JSONEncoder (optional)
  /// - Returns: Encoded data
  /// - Throws: Encoding errors
  func toData(_ encoder: JSONEncoder = JSONEncoder()) throws -> Data {
    let configuredEncoder = encoder
    configuredEncoder.dateEncodingStrategy = .iso8601
    return try configuredEncoder.encode(self)
  }
}

private extension Decodable {
  /// Decodes Data to a specific Decodable type with ISO8601 date decoding
  /// - Parameters:
  ///   - data: Data to decode
  ///   - decoder: Custom JSONDecoder (optional)
  /// - Returns: Decoded object
  /// - Throws: Decoding errors
  static func decode(_ data: Data, decoder: JSONDecoder = JSONDecoder()) throws -> Self {
    let configuredDecoder = decoder
    configuredDecoder.dateDecodingStrategy = .iso8601
    return try configuredDecoder.decode(Self.self, from: data)
  }

  /// Decodes a dictionary to a specific Decodable type
  /// - Parameter dict: Dictionary to decode
  /// - Returns: Decoded object
  /// - Throws: Decoding errors
  static func decode(_ dict: [String: Any]) throws -> Self {
    let data = try JSONSerialization.data(withJSONObject: dict, options: [])
    return try decode(data)
  }
}
