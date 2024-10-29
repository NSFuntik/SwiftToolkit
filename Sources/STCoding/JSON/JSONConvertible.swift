//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 30.03.2024.
//

import Foundation

// MARK: - JSONConvertible

/// Indicates that a type can be safely included in a JSON object without being converted to a string. In other words,
/// it may appear as a value without being quoted.
public protocol JSONConvertible {}

// MARK: - Double + JSONConvertible

extension Double: JSONConvertible {}

// MARK: - Float + JSONConvertible

extension Float: JSONConvertible {}

// MARK: - Bool + JSONConvertible

extension Bool: JSONConvertible {}

// MARK: - Int + JSONConvertible

extension Int: JSONConvertible {}

// MARK: - UInt + JSONConvertible

extension UInt: JSONConvertible {}

public func jsonConvertibleObject(_ value: some Any) -> Any {
	if case let reflectedStringConvertible as ReflectedStringConvertible = value {
		// handle ReflectedStringConvertibles recursively.
		return reflectedStringConvertible.dictionary(Mirror(reflecting: reflectedStringConvertible).allChildren)
	} else if value is JSONConvertible {
		let anyObject = value
		return anyObject
	} else if case let collection as JSONConvertibleCollection = value {
		return collection.jsonConvertibleObjects
	} else if case let dictionaryValue as JSONConvertibleDictionary = value {
		return dictionaryValue.jsonConvertibleElements
	} else {
		return String(describing: value)
	}
}

// MARK: - JSONConvertibleCollection

protocol JSONConvertibleCollection {
	var jsonConvertibleObjects: [Any] { get }
}

// MARK: - JSONConvertibleDictionary

public protocol JSONConvertibleDictionary {
	var jsonConvertibleElements: [String: Any] { get }
}

// MARK: - Array + JSONConvertibleCollection

extension Array: JSONConvertibleCollection {
	public var jsonConvertibleObjects: [Any] {
		map { jsonConvertibleObject($0) }
	}
}

// MARK: - Set + JSONConvertibleCollection

extension Set: JSONConvertibleCollection {
	public var jsonConvertibleObjects: [Any] {
		map { jsonConvertibleObject($0) }
	}
}

// MARK: - Dictionary + JSONConvertibleDictionary

extension Dictionary: JSONConvertibleDictionary {
	public var jsonConvertibleElements: [String: Any] {
		var dict: [String: Any] = [:]
		for (key, value) in self {
			dict[String(describing: key)] = jsonConvertibleObject(value)
		}

		return dict
	}

	public var jsonElements: [String: Any?] {
		var dict: [String: Any] = [:]
		for (key, value) in self {
			dict[String(describing: key)] = jsonConvertibleObject(value)
		}

		return dict
	}
}

// MARK: - ReflectedStringConvertible

/// A protocol that extends CustomStringConvertible to add a detailed textual representation to any class.
///
/// Two styles are supported:
/// - `Normal`: Similar to Swift's default textual representation of structs.
/// - `JSON`: Pretty JSON representation.
public protocol ReflectedStringConvertible: CustomStringConvertible {}

// MARK: - Style

/// The textual representation style.
public enum Style {
	/// Similar to the default textual representation of structs.
	case normal
	/// Pretty JSON style.
	case json
}

public extension ReflectedStringConvertible {
	/// A detailed textual representation of `self`.
	///
	/// - parameter style: The style of the textual representation.
	func reflectedDescription(_ style: Style) -> String {
		switch style {
		case .normal:
			description
		case .json:
			jsonDescription
		}
	}

	/// A `Normal` style detailed textual representation of `self`. This is the same as calling
	/// `reflectedDescription(.normal)`
	var description: String {
		let mirror = Mirror(reflecting: self)

		let descriptions: [String] = mirror
			.allChildren
			.sorted {
				$0.label ?? "" < $1.label ?? ""
			}
			.compactMap { (label: String?, value: Any) in
				if let label {
					var value = value

					if value is String {
						value = "\"\(value)\""
					}

					return "\(label): \(value)"
				}

				return nil
			}

		return "\(mirror.subjectType)(\(descriptions.joined(separator: ", ")))"
	}

	/// A `JSON` style detailed textual representation of `self`.
	private var jsonDescription: String {
		let dictionary = dictionary(Mirror(reflecting: self).allChildren)
		guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted, .sortedKeys])
		else {
			return "{}"
		}
		return String(data: data, encoding: String.Encoding.utf8)!
	}

	/// A dictionary representation of a `Mirror`'s children. Any child that conforms to `ReflectedStringConvertible` is
	/// handled recursively.
	fileprivate func dictionary(_ children: [Mirror.Child]) -> [String: Any] {
		var dictionary: [String: Any] = [:]

		for child in children {
			if let label = child.label {
				dictionary[label] = jsonConvertibleObject(child.value)
			}
		}

		return dictionary
	}
}

public extension Mirror {
	/// The children of the mirror and its superclasses.
	var allChildren: [Mirror.Child] {
		var children = Array(children)

		var superclassMirror = superclassMirror

		while let mirror = superclassMirror {
			children.append(contentsOf: mirror.children)
			superclassMirror = mirror.superclassMirror
		}

		return children
	}
}

// MARK: - JSONCodingKeys

// Inspired by https://gist.github.com/mbuchetics/c9bc6c22033014aa0c550d3b4324411a

public struct JSONCodingKeys: CodingKey {
	public var stringValue: String

	public init?(stringValue: String) {
		self.stringValue = stringValue
	}

	public var intValue: Int?

	public init?(intValue: Int) {
		self.init(stringValue: "\(intValue)")
		self.intValue = intValue
	}
}

public extension KeyedDecodingContainer {
	func decode(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any] {
		let container = try nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
		return try container.decode(type)
	}

	func decodeIfPresent(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any]? {
		guard contains(key) else {
			return nil
		}
		guard (try? decodeNil(forKey: key) == false) != nil else {
			return nil
		}
		return try? decode(type, forKey: key)
	}

	func decode(_ type: [Any].Type, forKey key: K) throws -> [Any] {
		var container = try nestedUnkeyedContainer(forKey: key)
		return try container.decode(type)
	}

	func decodeIfPresent(_ type: [Any].Type, forKey key: K) throws -> [Any]? {
		guard contains(key) else {
			return nil
		}
		guard try decodeNil(forKey: key) == false else {
			return nil
		}
		return try decode(type, forKey: key)
	}

	func decode(_: [String: Any].Type) throws -> [String: Any] {
		var dictionary = [String: Any]()

		for key in allKeys {
			if let boolValue = try? decode(Bool.self, forKey: key) {
				dictionary[key.stringValue] = boolValue
			} else if let stringValue = try? decode(String.self, forKey: key) {
				dictionary[key.stringValue] = stringValue
			} else if let intValue = try? decode(Int.self, forKey: key) {
				dictionary[key.stringValue] = intValue
			} else if let doubleValue = try? decode(Double.self, forKey: key) {
				dictionary[key.stringValue] = doubleValue
			} else if let nestedDictionary = try? decode([String: Any].self, forKey: key) {
				dictionary[key.stringValue] = nestedDictionary
			} else if let nestedArray = try? decode([Any].self, forKey: key) {
				dictionary[key.stringValue] = nestedArray
			}
		}
		return dictionary
	}
}

public extension UnkeyedDecodingContainer {
	mutating func decode(_: [Any].Type) throws -> [Any] {
		var array: [Any] = []
		while isAtEnd == false {
			// See if the current value in the JSON array is `null` first and prevent infite recursion with nested arrays.
			if try decodeNil() {
				continue
			} else if let value = try? decode(Bool.self) {
				array.append(value)
			} else if let value = try? decode(Double.self) {
				array.append(value)
			} else if let value = try? decode(String.self) {
				array.append(value)
			} else if let nestedDictionary = try? decode([String: Any].self) {
				array.append(nestedDictionary)
			} else if let nestedArray = try? decode([Any].self) {
				array.append(nestedArray)
			}
		}
		return array
	}

	mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
		let nestedContainer = try nestedContainer(keyedBy: JSONCodingKeys.self)
		return try nestedContainer.decode(type)
	}
}
