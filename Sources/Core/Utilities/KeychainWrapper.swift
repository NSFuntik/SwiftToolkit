import Foundation

private let paramSecMatchLimit = kSecMatchLimit as String
private let paramSecReturnData = kSecReturnData as String
private let paramSecReturnPersistentRef = kSecReturnPersistentRef as String
private let paramSecValueData = kSecValueData as String
private let paramSecAttrAccessible = kSecAttrAccessible as String
private let paramSecClass = kSecClass as String
private let paramSecAttrService = kSecAttrService as String
private let paramSecAttrGeneric = kSecAttrGeneric as String
private let paramSecAttrAccount = kSecAttrAccount as String
private let paramSecAttrAccessGroup = kSecAttrAccessGroup as String
private let paramSecReturnAttributes = kSecReturnAttributes as String

// MARK: - KeychainWrapper

/// This class help make device keychain access easier in Swift.
/// It is designed to make accessing the Keychain services more
/// like using `NSUserDefaults`, which is much more familiar to
/// developers in general.
///
/// `serviceName` is used for `kSecAttrService`, which uniquely
/// identifies keychain accessors. If no name is specified, the
/// value defaults to the current bundle identifier.
///
/// `accessGroup` is used for `kSecAttrAccessGroup`. This value
/// is used to identify which keychain access group an entry is
/// belonging to. This allows you to use `KeychainWrapper` with
/// shared keychain access between different applications.
///
/// `NOTE` In SwiftKit, you can use a `StandardKeychainService`
/// to isolate keychain access from contract design.
open class KeychainWrapper {
  // MARK: - Initialization

  /// Create a standard instance of this class.
  private convenience init() {
    let id = Bundle.main.bundleIdentifier
    let fallback = "dev.swifttoolkit.keychain"
    self.init(serviceName: id ?? fallback)
  }

  /// Create a custom instance of this class.
  ///
  /// The `serviceName` is used to uniquely identify every
  /// key that has been stored in the keychain, using this
  /// wrapper instance.
  ///
  /// Use matching access groups between applications when
  /// you want to allow shared keychain access.
  ///
  /// - Parameters:
  ///   - serviceName: The service name to use for this instance.
  ///   - accessGroup: An optional, unique access group for this instance.
  public init(
    serviceName: String,
    accessGroup: String? = nil
  ) {
    self.serviceName = serviceName
    self.accessGroup = accessGroup
  }

  // MARK: - Properties

  /// A standard keychain wrapper instance.
  public static let standard = KeychainWrapper()

  /// The service name to use for this instance.
  private let serviceName: String

  /// An optional, unique access group for this instance.
  private let accessGroup: String?

  // MARK: - KeychainReader

  open func bool(for key: String) -> Bool? {
    number(for: key)?.boolValue
  }

  open func data(for key: String) -> Data? {
    var dict = setupKeychainQueryDictionary(forKey: key)
    var result: AnyObject?
    dict[paramSecMatchLimit] = kSecMatchLimitOne
    dict[paramSecReturnData] = kCFBooleanTrue
    let status = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(dict as CFDictionary, UnsafeMutablePointer($0))
    }
    return status == noErr ? result as? Data : nil
  }

  open func double(for key: String) -> Double? {
    number(for: key)?.doubleValue
  }

  open func float(for key: String) -> Float? {
    number(for: key)?.floatValue
  }

  open func hasValue(for key: String) -> Bool {
    data(for: key) != nil
  }

  open func integer(for key: String) -> Int? {
    number(for: key)?.intValue
  }

  open func number(for key: String) -> NSNumber? {
    object(for: key)
  }

  open func object<T: NSObject & NSCoding>(for key: String) -> T? {
    guard let keychainData = data(for: key) else { return nil }
    return try? NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: keychainData)
  }

  open func string(for key: String) -> String? {
    guard let keychainData = data(for: key) else { return nil }
    return String(data: keychainData, encoding: String.Encoding.utf8) as String?
  }

  open func dataRef(for key: String) -> Data? {
    var dict = setupKeychainQueryDictionary(forKey: key)
    var result: AnyObject?
    dict[paramSecMatchLimit] = kSecMatchLimitOne
    dict[paramSecReturnPersistentRef] = kCFBooleanTrue
    let status = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(dict as CFDictionary, UnsafeMutablePointer($0))
    }
    return status == noErr ? result as? Data : nil
  }

  // MARK: - KeychainWriter

  @discardableResult
  open func set(_ value: Int, for key: String) -> Bool {
    set(NSNumber(value: value), for: key)
  }

  @discardableResult
  open func set(_ value: Float, for key: String) -> Bool {
    set(NSNumber(value: value), for: key)
  }

  @discardableResult
  open func set(_ value: Double, for key: String) -> Bool {
    set(NSNumber(value: value), for: key)
  }

  @discardableResult
  open func set(_ value: Bool, for key: String) -> Bool {
    set(NSNumber(value: value), for: key)
  }

  @discardableResult
  open func set(_ value: String, for key: String) -> Bool {
    guard let data = value.data(using: .utf8) else { return false }
    return set(data, for: key)
  }

  @discardableResult
  open func set(_ value: NSCoding, for key: String) -> Bool {
    guard let data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false) else {
      return false
    }
    return set(data, for: key)
  }

  @discardableResult
  open func set(_ value: Data, for key: String) -> Bool {
    var dict: [String: Any] = setupKeychainQueryDictionary(forKey: key)
    dict[paramSecValueData] = value

    // Assign default protection - Protect the keychain entry so it's only valid when the device is unlocked
    dict[paramSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock

    let status = SecItemAdd(dict as CFDictionary, nil)
    if status == errSecDuplicateItem {
      return update(value, forKey: key)
    }
    return status == errSecSuccess
  }

  @discardableResult
  open func removeObject(for key: String) -> Bool {
    let keychainQueryDictionary: [String: Any] = setupKeychainQueryDictionary(forKey: key)
    let status = SecItemDelete(keychainQueryDictionary as CFDictionary)
    return status == errSecSuccess
  }

  /// Remove all items from the device keychain, that were
  /// added by this wrapper.
  open func removeAllKeys() -> Bool {
    var dict: [String: Any] = [paramSecClass: kSecClassGenericPassword]
    dict[paramSecAttrService] = serviceName
    if let accessGroup {
      dict[paramSecAttrAccessGroup] = accessGroup
    }
    let status = SecItemDelete(dict as CFDictionary)
    return status == errSecSuccess
  }

  /// Remove all items from the device keychain, including
  /// entries that were not added by this wrapper.
  ///
  /// > Warning: This will remove all data from the store.
  open class func wipeKeychain() {
    deleteKeychainSecClass(kSecClassGenericPassword)  // Generic password items
    deleteKeychainSecClass(kSecClassInternetPassword)  // Internet password items
    deleteKeychainSecClass(kSecClassCertificate)  // Certificate items
    deleteKeychainSecClass(kSecClassKey)  // Cryptographic key items
    deleteKeychainSecClass(kSecClassIdentity)  // Identity items
  }
}

// MARK: - Private Methods

extension KeychainWrapper {
  /// Remove all items for a given Keychain Item Class.
  @discardableResult
  fileprivate class func deleteKeychainSecClass(_ secClass: AnyObject) -> Bool {
    let query = [paramSecClass: secClass]
    let status = SecItemDelete(query as CFDictionary)
    return status == errSecSuccess
  }

  /// Update all data that's associated with a certain key.
  ///
  /// Any existing data will be overwritten.
  fileprivate func update(
    _ value: Data,
    forKey key: String
  ) -> Bool {
    let keychainQueryDictionary: [String: Any] = setupKeychainQueryDictionary(forKey: key)
    let updateDictionary = [paramSecValueData: value]

    let status = SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary as CFDictionary)
    return status == errSecSuccess
  }

  /// Setup the keychain query dictionary.
  ///
  /// The dictionary is used to access the keychain on iOS
  /// for a certain key, taking into account service names
  /// and access groups, whenever set.
  ///
  /// - Parameters:
  ///   - forKey: The key this query is for.
  ///   - accessibility: Optional keychain accessibility.
  ///
  /// - returns: A dictionary with all properties needed to access the keychain on iOS.
  fileprivate func setupKeychainQueryDictionary(
    forKey key: String
  ) -> [String: Any] {
    var dict: [String: Any] = [paramSecClass: kSecClassGenericPassword]
    dict[paramSecAttrService] = serviceName
    dict[paramSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock

    if let accessGroup = self.accessGroup {
      dict[paramSecAttrAccessGroup] = accessGroup
    }
    let encodedIdentifier = key.data(using: String.Encoding.utf8)
    dict[paramSecAttrGeneric] = encodedIdentifier
    dict[paramSecAttrAccount] = encodedIdentifier
    return dict
  }
}

// MARK: - KeychainService

/// This class can be used to read from and write to the device
/// keychain, using a ``KeychainWrapper``.
open class KeychainService {
  public init(
    wrapper: KeychainWrapper = .standard
  ) {
    self.wrapper = wrapper
  }

  private let wrapper: KeychainWrapper

  // MARK: - KeychainReader

  open func accessibility(for key: String) -> CFString {
    kSecAttrAccessibleAfterFirstUnlock
  }

  open func bool(for key: String) -> Bool? {
    wrapper.bool(for: key)
  }

  open func data(for key: String) -> Data? {
    wrapper.data(for: key)
  }

  open func dataRef(for key: String) -> Data? {
    wrapper.dataRef(for: key)
  }

  open func double(for key: String) -> Double? {
    wrapper.double(for: key)
  }

  open func float(for key: String) -> Float? {
    wrapper.float(for: key)
  }

  open func hasValue(for key: String) -> Bool {
    wrapper.hasValue(for: key)
  }

  open func integer(for key: String) -> Int? {
    wrapper.integer(for: key)
  }

  open func string(for key: String) -> String? {
    wrapper.string(for: key)
  }

  // MARK: - KeychainWriter

  @discardableResult
  open func removeObject(for key: String) -> Bool {
    wrapper.removeObject(for: key)
  }

  open func removeAllKeys() -> Bool {
    wrapper.removeAllKeys()
  }

  @discardableResult
  open func set(_ value: Bool, for key: String) -> Bool {
    wrapper.set(value, for: key)
  }

  @discardableResult
  open func set(_ value: Data, for key: String) -> Bool {
    wrapper.set(value, for: key)
  }

  @discardableResult
  open func set(_ value: Double, for key: String) -> Bool {
    wrapper.set(value, for: key)
  }

  @discardableResult
  open func set(_ value: Float, for key: String) -> Bool {
    wrapper.set(value, for: key)
  }

  @discardableResult
  open func set(_ value: Int, for key: String) -> Bool {
    wrapper.set(value, for: key)
  }

  @discardableResult
  open func set(_ value: NSCoding, for key: String) -> Bool {
    wrapper.set(value, for: key)
  }

  @discardableResult
  open func set(_ value: String, for key: String) -> Bool {
    wrapper.set(value, for: key)
  }
}

extension KeychainService {
  /// A shared service singleton.
  public static var shared: KeychainService { .init() }
}
