import Foundation

public extension Optional where Wrapped: Collection {
  /// A Boolean value indicating whether the collection is empty.
  var isEmpty: Bool {
    self?.endIndex == self?.startIndex
  }

  /// A Boolean value indicating whether the collection is non-empty.
  var nonEmpty: Bool {
    self?.endIndex != self?.startIndex
  }
}

public extension Array {
  @inlinable
  /// Returns an optional array that is nil if the array is empty, otherwise returns itself.
  var nilOrEmpty: Self? {
    isEmpty ? nil : self
  }

  @inlinable
  /// Appends the contents of another array to this array and returns the resulting array.
  ///
  /// - Parameter other: The array of elements to append.
  /// - Returns: A new array containing the elements of both arrays.
  func appending(contentsOf other: [Element]) -> [Element] {
    var result = self
    result.append(contentsOf: other)
    return result
  }

  @inlinable
  /// The index of the last element in the array.
  var lastIndex: Int { endIndex - 1 }
}

public extension Collection {
  /// Returns an array of tuples containing each element's index and its corresponding value.
  func indexed() -> [(offset: Int, element: Element)] {
    Array(enumerated())
  }

  /// Creates an asynchronous map, transforming each element into another type.
  ///
  /// - Parameter transform: A closure that transforms an element asynchronously.
  /// - Returns: An array containing the transformed elements.
  func asyncMap<T>(
    _ transform: (Element) async throws -> T
  ) async rethrows -> [T] {
    var values = [T]()
    for element in self {
      try await values.append(transform(element))
    }
    return values
  }

  /// Creates an asynchronous compact map, transforming each element and removing nil results.
  ///
  /// - Parameter transform: A closure that transforms an element asynchronously and possibly returns nil.
  /// - Returns: An array containing the non-nil transformed elements.
  func asyncCompactMap<T>(
    _ transform: (Element) async throws -> T?
  ) async rethrows -> [T] {
    var values = [T]()
    for element in self {
      if let el = try await transform(element) {
        values.append(el)
      }
    }
    return values
  }
}

public extension Array where Element: Identifiable & Equatable, Index == Int {
  /// A subscript that safely retrieves or sets an element at a specified index.
  ///
  /// If the index is out of bounds, it returns nil instead of crashing.
  subscript(safe index: Int) -> Element? {
    get {
      indices.contains(index) ? self[index] : nil
    }
    set {
      guard indices.contains(index) else {
        debugPrint("There is NO value for index: \(index)")
        if underestimatedCount > index {}
        return
      }
      if let newValue {
        self[safe: index] = newValue
      } else {
        remove(at: index)
      }
    }
  }
}

public extension RangeReplaceableCollection where Element: Identifiable & Equatable, Index == Int {
  /// A subscript that safely retrieves or sets an element at a specified index.
  ///
  /// If the index is out of bounds, it returns nil instead of crashing.
  subscript(safe index: Int) -> Element? {
    get {
      indices.contains(index) ? self[index] : nil
    }
    set {
      guard indices.contains(index) else {
        debugPrint("There is NO value for index: \(index)")
        if underestimatedCount > index {}
        return
      }
      if let newValue {
        self[safe: index] = newValue
      } else {
        remove(at: index)
      }
    }
  }
}

public extension RangeReplaceableCollection where Index: Hashable {
  /// A Boolean value indicating whether the collection has content.
  var hasContent: Bool {
    !isEmpty
  }

  /// Removes elements at the specified collection of indices.
  ///
  /// - Parameter collection: A collection of indices at which to remove elements.
  /// - Returns: The elements that were removed.
  mutating func removeAll(at collection: some Collection<Index>) -> Self {
    let indices = Set(collection)
    // Trap if number of elements in the set is different from the collection.
    // Trap if an index is out of range.
    precondition(
      indices.count == collection.count &&
        indices.allSatisfy(self.indices.contains)
    )
    return indices
      .lazy
      .sorted()
      .enumerated()
      .reduce(into: .init()) { result, value in
        let (offset, index) = value
        if offset == 0 {
          result.reserveCapacity(indices.count)
        }
        let shiftedIndex = self.index(index, offsetBy: -offset)
        let element = remove(at: shiftedIndex)
        result.append(element)
      }
  }
}

public extension Sequence where Iterator.Element: Hashable & Comparable {
  /// Groups the sequence into a dictionary based on a specified property.
  ///
  /// The operation can use any property from the items as the dictionary key.
  ///
  /// - Parameter grouper: A closure that defines the grouping criterion.
  /// - Returns: A dictionary where keys are the result of the grouper closure, and values are arrays of elements.
  func grouped<T>(by grouper: (Element) -> T) -> [T: [Element]] {
    Dictionary(grouping: self, by: grouper)
  }

  /// Returns an array containing the unique elements of the sequence.
  func unique() -> [Iterator.Element] {
    let reduced = reduce(into: Set<Iterator.Element>()) { partialResult, element in
      partialResult.update(with: element)
    }
    return Array(reduced)
  }

  /// Returns an array containing unique elements defined by a comparison closure.
  ///
  /// - Parameter areInIncreasingOrder: A closure that defines the comparison for uniqueness.
  /// - Returns: An array containing the unique elements.
  func unique(by areInIncreasingOrder: (Iterator.Element, Iterator.Element) -> Bool) -> [Iterator.Element] {
    var uniqueElements: Set<Iterator.Element> = []
    forEach { element in
      if !uniqueElements.contains(where: { areInIncreasingOrder($0, element) }) {
        uniqueElements.insert(element)
      }
    }
    return Array(uniqueElements)
  }
}

extension Array where Element: Hashable {
  /// Filters the array to remove duplicates based on a specified key path.
  ///
  /// - Parameter keyPath: A key path used to derive the value for duplication checks.
  mutating func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) {
    var seen = Set<T>()
    self = filter { element in
      seen.insert(element[keyPath: keyPath]).inserted
    }
  }
}

extension Array where Element: Comparable & Hashable {
  /// Removes duplicates from the array then sorts it.
  ///
  /// - Parameter keyPath: A key path used for unique checks and for sorting the array.
  mutating func sortedUnique(by keyPath: KeyPath<Element, some Hashable>) {
    self.unique(by: keyPath)
    self.sort()
  }
}

public extension Dictionary where Value == Any? {
  /// Returns a new dictionary without nil values.
  ///
  /// - Returns: A new dictionary with non-nil values.
  func removingNilValues() -> [Key: Any] {
    compactMapValues {
      guard let value = $0 else {
        return nil
      }
      return value
    }
  }
}
