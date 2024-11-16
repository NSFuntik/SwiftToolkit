import Foundation
import RegexBuilder

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif
extension String {
  /// Returns the character at the given index.
  public subscript(value: Int) -> Character {
    self[index(at: value)]
  }
}

extension String {
  @available(*, deprecated, message: "Use the new options-based version instead.")
  /// Replaces occurrences of a string with another string, with an option for case sensitivity.
  public func replacing(
    _ string: String,
    with: String,
    caseSensitive: Bool
  ) -> String {
    caseSensitive
      ? replacingOccurrences(of: string, with: with)
      : replacingOccurrences(of: string, with: with, options: .caseInsensitive)
  }

  /// Replace a certain string with another one.
  ///
  /// - Parameters:
  ///   - string: The string to be replaced.
  ///   - other: The string to replace with.
  ///   - options: Options for the comparison.
  /// - Returns: A new string with the replacements.
  public func replacing(
    _ string: String,
    with other: String,
    _ options: NSString.CompareOptions? = nil
  ) -> String {
    if let options {
      replacingOccurrences(of: string, with: other, options: options)
    } else {
      replacingOccurrences(of: string, with: other)
    }
  }

  /// Replace a certain string with another one and mutate the original string.
  ///
  /// - Parameters:
  ///   - string: The string to be replaced.
  ///   - other: The string to replace with.
  ///   - options: Options for the comparison.
  public mutating func replace(
    _ string: String,
    with other: String,
    _ options: NSString.CompareOptions? = nil
  ) {
    self = replacing(string, with: other, options)
  }

  /// This is a shorthand for `trimmingCharacters(in:)`.
  ///
  /// - Parameter set: The set of characters to trim.
  /// - Returns: A new string with specified characters trimmed.
  public func trimmed(
    for set: CharacterSet = .whitespacesAndNewlines
  ) -> String {
    trimmingCharacters(in: set)
  }

  /// Checks if this string has any content.
  public var hasContent: Bool {
    !isEmpty
  }

  /// Returns `nil` if the string is empty or whitespace, otherwise returns the string itself.
  public var nilIfEmpty: String? {
    hasTrimmedContent ? self : nil
  }

  /// Checks if this string has any content after trimming.
  public var hasTrimmedContent: Bool {
    !trimmingCharacters(in: .whitespacesAndNewlines).replacing("–", with: "").isEmpty
  }

  /// Checks if this string contains another string, with an option for case sensitivity.
  ///
  /// - Parameters:
  ///   - string: The string to check for.
  ///   - caseSensitive: Whether the check should be case sensitive.
  /// - Returns: A boolean indicating whether the string was found.
  public func contains(_ string: String, caseSensitive: Bool = false) -> Bool {
    caseSensitive
      ? localizedStandardContains(string)
      : range(of: string, options: .caseInsensitive) != nil
  }

  /// Checks if this string is a member of the given sequence of strings.
  ///
  /// - Parameter sequence: An array of strings to check against.
  /// - Returns: A boolean indicating if this string is in the sequence.
  public func isMember(of sequence: [String]) -> Bool {
    sequence.map(\.localizedLowercase).contains(self.localizedLowercase)
  }

  /// Checks if this string is equal to another string, with an option for case sensitivity.
  ///
  /// - Parameters:
  ///   - string: The string to compare with.
  ///   - caseSensitive: Whether the comparison should be case sensitive.
  /// - Returns: A boolean indicating if the strings are equal.
  public func equals(_ string: String, caseSensitive: Bool = false) -> Bool {
    if caseSensitive {
      return self == string
    } else {
      return self.lowercased() == string.lowercased()
    }
  }
}

extension String {
  /// Returns the date parsed from the string in ISO8601 format.
  public var date: Date? {
    ISO8601DateFormatter.full.date(from: self)
  }

  /// Returns the last path component of the string, treated as a URL.
  public var lastPathComponent: String {
    guard let url = URL(string: self) else {
      return self
    }
    return url.lastPathComponent
  }

  /// Returns the path extension of the string, treated as a URL.
  public var pathExtension: String {
    guard let url = URL(string: self) else {
      debugPrint("Invalid URL: \(self)")
      return components(separatedBy: ".").last ?? ""
    }
    return url.pathExtension
  }

  /// Returns a substring for the specified NSRange.
  public subscript(value: NSRange) -> Substring {
    self[value.lowerBound..<value.upperBound]
  }
}

extension String {
  /// An empty string constant.
  public static var none: String { "" }
  /// Returns a substring for the specified closed range.
  public subscript(value: CountableClosedRange<Int>) -> Substring {
    self[index(at: value.lowerBound)...index(at: value.upperBound)]
  }

  /// Returns a substring for the specified range.
  public subscript(value: CountableRange<Int>) -> Substring {
    self[index(at: value.lowerBound)..<index(at: value.upperBound)]
  }

  /// Returns a substring for the specified partial range up to a particular index.
  public subscript(value: PartialRangeUpTo<Int>) -> Substring {
    self[..<index(at: value.upperBound)]
  }

  /// Returns a substring for the specified partial range through a particular index.
  public subscript(value: PartialRangeThrough<Int>) -> Substring {
    self[...index(at: value.upperBound)]
  }

  /// Returns a substring for the specified partial range from a particular index.
  public subscript(value: PartialRangeFrom<Int>) -> Substring {
    self[index(at: value.lowerBound)...]
  }
}

extension String {
  /// Returns the index at a given offset.
  ///
  /// - Parameter offset: The integer offset.
  /// - Returns: The index at the specified offset.
  fileprivate func index(at offset: Int) -> String.Index {
    index(startIndex, offsetBy: offset)
  }
}

extension String? {
  /// Checks if the string matches a given regex pattern.
  ///
  /// - Parameter regex: The regex pattern to match against.
  /// - Returns: A boolean indicating if the string matches the regex.
  public func matches(regex: String?) -> Bool {
    guard let self, !self.isEmpty, self.endIndex.utf16Offset(in: self) > 2 else {
      return false
    }
    guard let regex, !regex.isEmpty else {
      return true
    }
    guard let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive) else {
      return false
    }
    let range = NSRange(location: 0, length: self.utf16.underestimatedCount)
    return regex.firstMatch(in: self, options: [], range: range) != nil
  }
}

extension String {
  /// Checks if the string matches a given regex pattern.
  ///
  /// - Parameter regex: The regex pattern to match against.
  /// - Returns: A boolean indicating if the string matches the regex.
  public func matches(regex: String) -> Bool {
    guard !isEmpty, endIndex.utf16Offset(in: self) > 2 else {
      return false
    }
    guard !regex.isEmpty else {
      return true
    }
    guard let regex = try? NSRegularExpression(pattern: regex, options: .caseInsensitive) else {
      return false
    }
    let range = NSRange(location: 0, length: utf16.underestimatedCount)
    return regex.firstMatch(in: self, options: [], range: range) != nil
  }

  /// Masks the string based on a regex pattern and returns the masked string.
  ///
  /// - Parameter regex: The regex pattern to mask.
  /// - Returns: The masked string.
  public func mask(with regex: String) -> String {
    let regularex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive, .ignoreMetacharacters])
    let output =
      regularex?.stringByReplacingMatches(
        in: self,
        options: [.reportCompletion],
        range: NSRange(location: 0, length: utf16.count),
        withTemplate:
          NSRegularExpression.escapedTemplate(for: regex).capitalized
      ) ?? self
    debugPrint("escapedTemplate: \(NSRegularExpression.escapedTemplate(for: regex))")
    debugPrint("\(output)")
    return output
  }

  /// Formats a string according to a given mask.
  ///
  /// - Parameters:
  ///   - mask: The mask to use for formatting.
  ///   - symbol: The symbol in the mask used for inserting characters.
  /// - Returns: The formatted string.
  public func format(with mask: String = "+X (XXX) XXX XX XX", symbol: Character = "X") -> String {
    let cleanNumber = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    var result = ""
    var startIndex = cleanNumber.startIndex
    let endIndex = cleanNumber.endIndex
    for char in mask where startIndex < endIndex {
      if char == symbol {
        result.append(cleanNumber[startIndex])
        startIndex = cleanNumber.index(after: startIndex)
      } else {
        result.append(char)
      }
    }
    return result
  }

  #if canImport(UIKit)
  /// Calculates the width of the string when constrained to a specific width and with a specific font.
  ///
  /// - Parameters:
  ///   - width: The width constraint.
  ///   - font: The font to use for measurement.
  ///   - messageUseMarkdown: Indicates whether markdown should be used.
  /// - Returns: The calculated width.
  func width(
    withConstrainedWidth width: CGFloat,
    font: UIFont,
    messageUseMarkdown: Bool
  ) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = toAttrString(font: font, messageUseMarkdown: messageUseMarkdown)
      .boundingRect(
        with: constraintRect,
        options: .usesLineFragmentOrigin,
        context: nil
      )
    return ceil(boundingBox.width)
  }

  /// Converts the string to an attributed string with given font and markdown options.
  ///
  /// - Parameters:
  ///   - font: The font to use for the attributed string.
  ///   - messageUseMarkdown: Indicates whether markdown should be parsed.
  /// - Returns: The resulting NSAttributedString.
  func toAttrString(
    font: UIFont = .preferredFont(forTextStyle: .body),
    messageUseMarkdown: Bool = true
  ) -> NSAttributedString {
    var str =
      messageUseMarkdown
      ? (try? AttributedString(
        markdown: self,
        options: AttributedString.MarkdownParsingOptions(
          allowsExtendedAttributes: true,
          interpretedSyntax: .inlineOnlyPreservingWhitespace,
          failurePolicy: .returnPartiallyParsedIfPossible,
          languageCode: nil
        )
      )) ?? AttributedString(self) : AttributedString(self)
    str.setAttributes(AttributeContainer([.font: font]))
    return NSAttributedString(str)
  }

  /// Calculates the width of the last line of the string within a specified width.
  ///
  /// - Parameters:
  ///   - labelWidth: The width constraint.
  ///   - font: The font to use.
  ///   - messageUseMarkdown: Indicates whether markdown should be used.
  /// - Returns: The width of the last line.
  func lastLineWidth(
    labelWidth: CGFloat,
    font: UIFont,
    messageUseMarkdown: Bool
  ) -> CGFloat {
    // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
    let attrString = toAttrString(font: font, messageUseMarkdown: messageUseMarkdown)
    let availableSize = CGSize(width: labelWidth, height: .infinity)
    let layoutManager = NSLayoutManager()
    let textContainer = NSTextContainer(size: availableSize)
    let textStorage = NSTextStorage(attributedString: attrString)
    // Configure layoutManager and textStorage
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    // Configure textContainer
    textContainer.lineFragmentPadding = 0.0
    textContainer.lineBreakMode = .byWordWrapping
    textContainer.maximumNumberOfLines = 0
    let lastGlyphIndex = layoutManager.glyphIndexForCharacter(at: attrString.length - 1)
    let lastLineFragmentRect = layoutManager.lineFragmentUsedRect(
      forGlyphAt: lastGlyphIndex,
      effectiveRange: nil
    )
    return lastLineFragmentRect.maxX
  }

  /// Calculates the number of lines needed to display the string within a specified width.
  ///
  /// - Parameters:
  ///   - labelWidth: The width constraint.
  ///   - font: The font to use.
  ///   - messageUseMarkdown: Indicates whether markdown should be used.
  /// - Returns: The number of lines required.
  func numberOfLines(
    labelWidth: CGFloat,
    font: UIFont,
    messageUseMarkdown: Bool
  ) -> Int {
    let attrString = toAttrString(font: font, messageUseMarkdown: messageUseMarkdown)
    let availableSize = CGSize(width: labelWidth, height: .infinity)
    let textSize = attrString.boundingRect(with: availableSize, options: .usesLineFragmentOrigin, context: nil)
    let lineHeight = font.lineHeight
    return Int(ceil(textSize.height / lineHeight))
  }
  #endif
}

extension String {
  /// Calculates the Levenshtein distance score to another string.
  ///
  /// - Parameters:
  ///   - string: The string to compare.
  ///   - caseSensitive: Whether the comparison should be case sensitive.
  ///   - trimWhiteSpacesAndNewLines: Whether to trim whitespaces and new lines before comparison.
  /// - Returns: A score between 0 and 1, where 1 means the strings are identical and 0 means they are completely different.
  public func levenshteinDistanceScore(
    to string: String,
    caseSensitive: Bool = false,
    trimWhiteSpacesAndNewLines: Bool = true
  ) -> Double {
    var firstString = self
    var secondString = string
    if !caseSensitive {
      firstString = firstString.lowercased()
      secondString = secondString.lowercased()
    }
    if trimWhiteSpacesAndNewLines {
      firstString = firstString.trimmingCharacters(in: .whitespacesAndNewlines)
      secondString = secondString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    let empty = [Int](repeating: 0, count: secondString.count)
    var last = [Int](0...secondString.count)
    for (i, tLett) in firstString.enumerated() {
      var cur = [i + 1] + empty
      for (j, sLett) in secondString.enumerated() {
        cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j]) + 1
      }
      last = cur
    }
    // maximum string length between the two
    let lowestScore = max(firstString.count, secondString.count)
    if let validDistance = last.last {
      return 1 - (Double(validDistance) / Double(lowestScore))
    }
    return 0.0
  }
}

extension [String] {
  /// Finds the most similar string in the array to the given string based on Levenshtein distance.
  ///
  /// - Parameter string: The string to compare against.
  /// - Returns: The most similar string, or nil if the array is empty.
  public func mostSimilar(to string: String) -> String? {
    guard !isEmpty else {
      return nil
    }
    return lazy.sorted { $0.levenshteinDistanceScore(to: string) > $1.levenshteinDistanceScore(to: string) }.first
  }
}
