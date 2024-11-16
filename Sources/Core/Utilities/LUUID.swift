import Foundation.NSUUID

// MARK: - LUUID

/// Represents **UUID RFC 4122 **version, which can be used to uniquely identify types, interfaces, and other items.
public struct LUUID: Hashable, Equatable, CustomStringConvertible, Sendable {
  // MARK: Lifecycle

  /// Create a new UUID with RFC 4122 version 4 random bytes
  public init() {
    withUnsafeMutablePointer(to: &self.uuid) {
      $0.withMemoryRebound(to: UInt8.self, capacity: 16) {
        uuid_generate_random($0)
      }
    }
  }

  /// Create a `UUID` from a string such as "e621e1f8-c36c-495a-93fc-0c247a3e6e5f".
  ///
  /// Returns nil for invalid strings.
  public init?(uuidString string: String?) {
    guard let string else {
      return nil
    }
    let res = withUnsafeMutablePointer(to: &self.uuid) {
      $0.withMemoryRebound(to: UInt8.self, capacity: 16) {
        uuid_parse(string, $0)
      }
    }
    if res != 0 {
      return nil
    }
  }

  /// Create a UUID from a `uuid_t`.
  public init(uuid: uuid_t) {
    self.uuid = uuid
  }

  /// Custom initializer to convert from an integer
  public init(from value: UInt64) {
    var bytes = [UInt8](repeating: 0, count: 16)
    for i in 0..<8 {
      bytes[15 - i] = UInt8((value >> (i * 8)) & 0xFF)
    }
    self.uuid = (
      bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7], bytes[8], bytes[9], bytes[10],
      bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
    )
  }

  // MARK: Public

  // Static Properties

  public static let null: Self = LUUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))

  // Properties

  public private(set) var uuid: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

  // Computed Properties

  /// Returns a string created from the UUID, such as "e621e1f8-c36c-495a-93fc-0c247a3e6e5f"
  public var uuidString: String {
    var bytes: uuid_string_t = (
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    )
    return withUnsafePointer(to: self.uuid) {
      $0.withMemoryRebound(to: UInt8.self, capacity: 16) { val in
        withUnsafeMutablePointer(to: &bytes) {
          $0.withMemoryRebound(to: Int8.self, capacity: 37) { str in
            uuid_unparse_lower(val, str)
            return String(cString: UnsafePointer(str), encoding: .utf8) ?? "Invalid UUID"
          }
        }
      }
    }
  }

  public var description: String {
    self.uuidString
  }

  public var debugDescription: String {
    self.description
  }

  // Static Functions

  public static func == (lhs: LUUID, rhs: LUUID) -> Bool {
    lhs.uuid.0 == rhs.uuid.0 && lhs.uuid.1 == rhs.uuid.1 && lhs.uuid.2 == rhs.uuid.2 && lhs.uuid.3 == rhs.uuid.3
      && lhs.uuid.4 == rhs.uuid.4 && lhs.uuid.5 == rhs.uuid.5 && lhs.uuid.6 == rhs.uuid.6 && lhs.uuid.7 == rhs.uuid.7
      && lhs.uuid.8 == rhs.uuid.8 && lhs.uuid.9 == rhs.uuid.9 && lhs.uuid.10 == rhs.uuid.10
      && lhs.uuid.11 == rhs.uuid.11 && lhs.uuid.12 == rhs.uuid.12 && lhs.uuid.13 == rhs.uuid.13
      && lhs.uuid.14 == rhs.uuid.14 && lhs.uuid.15 == rhs.uuid.15
  }

  // Functions

  public func hash(into hasher: inout Hasher) {
    withUnsafeBytes(of: self.uuid) {
      hasher.combine(bytes: $0)
    }
  }
}

// MARK: CustomReflectable

extension LUUID: CustomReflectable {
  public var customMirror: Mirror {
    let c: [(label: String?, value: Any)] = []
    return Mirror(self, children: c, displayStyle: Mirror.DisplayStyle.struct)
  }
}

// MARK: Codable

extension LUUID: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let uuid = try? container.decode(UUID.self) {
      self.init(uuid: uuid.uuid)
    } else if let uuidInt = try? container.decode(
      UInt.self
    ) {
      self.init(from: UInt64(uuidInt))
    } else if let uuidInt64 = try? container.decode(
      UInt64.self
    ) {
      self.init(from: uuidInt64)
    } else if let uuidString = try? container.decode(String.self) {
      guard let uuid = LUUID(uuidString: uuidString) else {
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid UUID string.")
      }
      self = uuid
    } else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Unable to decode UUID from provided data."
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.uuidString)
  }
}

extension LUUID {
  /// Returns a new UUID with RFC 4122 version 4 random bytes
  public func isEmpty() -> Bool {
    self == LUUID.null
  }

  /// Returns a new UUID with RFC 4122 version 4 random bytes
  public func nilIfEmpty() -> LUUID? {
    self.isEmpty() ? nil : self
  }
}
