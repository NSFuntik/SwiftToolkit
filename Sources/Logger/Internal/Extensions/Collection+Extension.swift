import Foundation

public extension RangeReplaceableCollection {
  /// Calculates the distance from a given start index to the end index of the collection.
  /// - Parameter startIndex: The starting index from which the distance is to be calculated.
  /// - Returns: The number of elements from the start index to the end index.
  private func distance(from startIndex: Index) -> Int {
    distance(from: startIndex, to: self.endIndex)
  }

  /// Calculates the distance from the start of the collection to a given end index.
  /// - Parameter endIndex: The ending index to which the distance is to be calculated.
  /// - Returns: The number of elements from the start index to the end index.
  private func distance(to endIndex: Index) -> Int {
    distance(from: self.startIndex, to: endIndex)
  }

  /// A safe subscript that returns an optional element at the specified index.
  /// If the index is out of bounds, it returns `nil`.
  /// - Parameter index: The index of the element to access.
  /// - Returns: The element at the specified index, or `nil` if the index is out of bounds.
  subscript(safe index: Index) -> Iterator.Element? {
    get {
      if distance(to: index) >= 0, distance(from: index) > 0 {
        return self[index]
      }
      return nil
    }
    set {
      if let newValue {
        self[safe: index] = newValue
      } else { self.remove(at: index) }
    }
  }

  /// A safe subscript that returns an optional subsequence for the specified range.
  /// If the range is out of bounds, it returns `nil`.
  /// - Parameter bounds: The range of the subsequence to access.
  /// - Returns: The subsequence within the specified bounds, or `nil` if the bounds are invalid.
  subscript(safe bounds: Range<Index>) -> SubSequence? {
    if distance(to: bounds.lowerBound) >= 0, distance(from: bounds.upperBound) >= 0 {
      return self[bounds]
    }
    return nil
  }

  /// A safe subscript that returns an optional subsequence for the specified closed range.
  /// If the range is out of bounds, it returns `nil`.
  /// - Parameter bounds: The closed range of the subsequence to access.
  /// - Returns: The subsequence within the specified closed bounds, or `nil` if the bounds are invalid.
  subscript(safe bounds: ClosedRange<Index>) -> SubSequence? {
    if distance(to: bounds.lowerBound) >= 0, distance(from: bounds.upperBound) > 0 {
      return self[bounds]
    }
    return nil
  }
}

public extension StaticString {
  /// Returns the last path component of the static string.
  /// If the static string cannot be converted to a URL, the original string is returned.
  /// - Returns: The last path component as a string.
  var lastPathComponent: String {
    guard let url = URL(string: self.description) else { return self.description }
    return url.lastPathComponent
  }
}
