import Foundation

public extension URLComponents {
  /// Sets the query items of the URL components with the provided parameters.
  /// - Parameter parameters: A dictionary of query parameters to set.
  mutating func setQueryItems(with parameters: [String: String]) {
    queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
  }
}

public extension URLRequest {
  /// A computed property to get and set the query items on the URL request.
  var queryItems: [URLQueryItem]? {
    get {
      guard let url = url else { return nil }
      guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
      return components.queryItems
    }
    set {
      guard let url = self.url else { return }
      var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
      components?.queryItems = newValue
      // Update the URL of the URLRequest if new query items are set
      guard let url = components?.url else { return }
      self.url = url
    }
  }
}

public extension URL {
  @available(iOS, introduced: 14, deprecated: 16, obsoleted: 16)
  /// Appends the given query items to the URL.
  /// - Parameter query: An array of URLQueryItem to append.
  /// - Returns: A new URL with the query items appended.
  func appending(query: [URLQueryItem]) -> URL {
    guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
      let percentEncodedQuery = "?".appending(query.compactMap { $0.name + (($0.value ?? "").isEmpty ? "" : "=".appending($0.value!)) }.joined(separator: "&"))
      debugPrint(percentEncodedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? percentEncodedQuery)
      return URL(string: self.absoluteString.appending(percentEncodedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? percentEncodedQuery)) ?? self.appending(path: percentEncodedQuery)
    }
    components.queryItems = query
    return self
  }

  /// Returns a URL constructed by appending the given path to self.
  /// - Parameters:
  ///   - path: The path to add
  ///   - directoryHint: A hint to whether this URL will point to a directory
  @available(iOS, introduced: 14, deprecated: 16, obsoleted: 16)
  func appending(
    path: String,
    isDirectory: Bool = false) -> URL {
    var url = self
    url.appendPathComponent(path, isDirectory: isDirectory)
    return url
  }

  @available(iOS, introduced: 14, deprecated: 16, obsoleted: 16)
  /// Appends the given path to the URL, inferring if it is a directory or not.
  /// - Parameters:
  ///   - path: The path to append.
  ///   - isDirectory: A Boolean indicating if the path is a directory.
  mutating func append(
    path: String,
    isDirectory: Bool = false) {
    self.appendPathComponent(path, isDirectory: isDirectory)
  }

  /// Appends the specified query items to the URL.
  /// - Parameter query: An array of URLQueryItem to append.
  mutating func append(query: [URLQueryItem]) {
    guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
      return
    }
    components.queryItems = query
    self = components.url ?? self
  }

  /// Returns a URL constructed by appending the specified query items.
  /// - Parameter query: An array of URLQueryItem to append.
  /// - Returns: A new URL with the query items appended, or nil if the query items cannot be appended.
  func appending(query: [URLQueryItem]) -> URL? {
    guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
      return nil
    }
    components.queryItems = query
    return components.url
  }

  /// Retrieves the attributes of the file at the URL's path.
  var attributes: [FileAttributeKey: Any]? {
    do {
      return try FileManager.default.attributesOfItem(atPath: path)
    } catch let error as NSError {
      print("FileAttribute error: \(error)")
    }
    return nil
  }

  /// The size of the file at the URL, in bytes.
  var fileSize: UInt64? {
    return attributes?[.size] as? UInt64
  }

  /// A string representing the size of the file at the URL, formatted for display.
  var fileSizeString: String? {
    guard let fileSize else { return nil }
    return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
  }

  /// The creation date of the file at the URL.
  var creationDate: Date? {
    return attributes?[.creationDate] as? Date
  }
}

/// @available on extension level sufficient as added functions do not match upcoming APIs exactly
@available(iOS, deprecated: 16.0, message: "URLCompatibilityKit is only useful when targeting iOS versions earlier than 16")
@available(macOS, deprecated: 13.0, message: "URLCompatibilityKit is only useful when targeting macOS versions earlier than 13")
@available(tvOS, deprecated: 16.0, message: "URLCompatibilityKit is only useful when targeting tvOS versions earlier than 16")
@available(watchOS, deprecated: 9.0, message: "URLCompatibilityKit is only useful when targeting watchOS versions earlier than 9")
public extension URL {
  /// Appends a path (inferring if it is directory or not) to the receiver.
  mutating func append<S>(path: S) where S: StringProtocol {
    if path.hasSuffix("/") {
      appendPathComponent("\(path)", isDirectory: true)
    } else {
      appendPathComponent("\(path)", isDirectory: false)
    }
  }

  /// Returns a URL constructed by appending the given path (inferring if it is directory or not) to self
  func appending<S>(path: S) -> URL where S: StringProtocol {
    if path.hasSuffix("/") {
      return appendingPathComponent("\(path)", isDirectory: true)
    } else {
      return appendingPathComponent("\(path)", isDirectory: false)
    }
  }
}

/// @available on method level needed to avoid "`Ambiguous use of ..." compiler error as added function/property does match upcoming API
public extension URL {
  /// The URL to the program’s current directory.
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static func currentDirectory() -> URL {
    URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
  }

  #if os(macOS)
    /// Home directory for the specified user.
    @available(iOS, introduced: 11.0, obsoleted: 16.0)
    @available(macOS, introduced: 10.12, obsoleted: 13.0)
    @available(tvOS, introduced: 10.0, obsoleted: 16.0)
    @available(watchOS, introduced: 3.0, obsoleted: 9.0)
    static func homeDirectory(forUser user: String) -> URL? {
      FileManager.default.homeDirectory(forUser: user)
    }
  #endif
}

public extension URL {
  /// Supported applications (/Applications).
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var application: URL {
    FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first!
  }

  /// Application support files (Library/Application Support).
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var applicationSupport: URL {
    FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
  }

  /// Discardable cache files (Library/Caches).
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var caches: URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }

  /// The user’s desktop directory.
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var desktop: URL {
    FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
  }

  /// Document directory.
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var documents: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  }

  /// The user’s downloads directory.
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var downloads: URL {
    FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
  }

  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var home: URL {
    URL(fileURLWithPath: NSHomeDirectory())
  }

  /// Various user-visible documentation, support, and configuration files (/Library).
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var library: URL {
    FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
  }

  /// The user’s Movies directory (~/Movies).
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var movies: URL {
    FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first!
  }

  /// The user’s Music directory (~/Music).
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var music: URL {
    FileManager.default.urls(for: .musicDirectory, in: .userDomainMask).first!
  }

  /// The user’s Pictures directory (~/Pictures).
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var pictures: URL {
    FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
  }

  /// The user’s Public sharing directory (~/Public).
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var sharedPublic: URL {
    FileManager.default.urls(for: .sharedPublicDirectory, in: .userDomainMask).first!
  }

  /// The temporary directory for the current user.
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var temporary: URL {
    URL(fileURLWithPath: NSTemporaryDirectory())
  }

  #if os(macOS)
    /// The trash directory.
    @available(iOS, introduced: 11.0, obsoleted: 16.0)
    @available(macOS, introduced: 10.12, obsoleted: 13.0)
    @available(tvOS, introduced: 10.0, obsoleted: 16.0)
    @available(watchOS, introduced: 3.0, obsoleted: 9.0)
    static var trash: URL {
      FileManager.default.urls(for: .trashDirectory, in: .localDomainMask).first!
    }
  #endif

  /// User home directories (/Users).
  @available(iOS, introduced: 11.0, obsoleted: 16.0)
  @available(macOS, introduced: 10.12, obsoleted: 13.0)
  @available(tvOS, introduced: 10.0, obsoleted: 16.0)
  @available(watchOS, introduced: 3.0, obsoleted: 9.0)
  static var user: URL {
    FileManager.default.urls(for: .userDirectory, in: .localDomainMask).first!
  }
}
