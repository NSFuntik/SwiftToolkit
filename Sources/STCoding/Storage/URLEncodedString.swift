import Foundation

// Extend URL to conform to ExpressibleByStringLiteral
extension URL: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension URL: @retroactive ExpressibleByUnicodeScalarLiteral {}

// MARK: - URL + ExpressibleByStringLiteral

extension URL: @retroactive ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    if let url = URL(string: value) {
      self = url
    } else {
      fatalError("Invalid URL string literal: \(value)")
    }
  }
}

// MARK: - SafeURL

/// Custom SafeURL type to handle decoding and encoding
struct SafeURL: Codable {
  let url: URL?

  init(url: URL?) {
    self.url = url
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let urlString = try? container.decode(String.self) {
      self.url = URL(string: urlString)
    } else {
      self.url = nil
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(url?.absoluteString)
  }
}
