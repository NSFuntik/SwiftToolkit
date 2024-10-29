import Foundation
#if canImport(UIKit)
  import UIKit

  public extension UIDevice {
    /// A Boolean value indicating whether the device is an iPad.
    static var isIPad: Bool {
      UIDevice.current.userInterfaceIdiom == .pad
    }

    /// A Boolean value indicating whether the device is an iPhone.
    static var isIPhone: Bool {
      UIDevice.current.userInterfaceIdiom == .phone
    }

    /// A string representation of a unique device identifier.
    ///
    /// This identifier is retrieved from the device's identifier for vendor,
    /// user defaults, or generated if no identifier exists. It persists even
    /// when the app is uninstalled.
    static var deviceId: String {
      if let uuid = UIDevice.current.identifierForVendor?.uuidString {
        debugPrint("IdentifierForVendor Device ID: \(uuid)")
        return uuid
      } else {
        debugPrint("Unable to retrieve device ID.")
        debugPrint("Requesting tracking authorization.")
        if let id = UserDefaults.standard.string(forKey: "deviceID") {
          debugPrint("UserDefaults Device ID: \(id)")
          return id
        } else {
          let id = LUUID().uuidString
          UserDefaults.standard.set(id, forKey: "deviceID")
          debugPrint("NEW UserDefaults Device ID: \(id)")
          return id
        }
      }
    }
  }

  /// This class can generate a unique device identifier that
  /// is persisted even when uninstalling the app.
  open class DeviceIdentifier {
    // Properties
    private let keychainService: KeychainService
    private let store: UserDefaults
    /// Lifecycle
    /// Create a device identifier.
    ///
    /// - Parameters:
    ///   - keychainService: The service to use for keychain support, by default `.shared`.
    ///   - keychainAccessibility: The keychain accessibility to use, by default `nil`.
    ///   - store: The user defaults to persist ID in, by default `.standard`.
    public init(
      keychainService: KeychainService,
      store: UserDefaults = .standard) {
      self.keychainService = keychainService
      self.store = store
    }

    /// Functions
    /// Get a unique device identifier from any store.
    ///
    /// If no device identifier exists, this identifier will
    /// generate a new identifier and persist it in both the
    /// keychain and in user defaults.
    open func getDeviceIdentifier() -> String {
      let keychainId = self.keychainService.string(for: key)
      let storeId = self.store.string(forKey: key)
      let id = LUUID(uuidString: (keychainId ?? storeId) ?? LUUID().uuidString) ?? LUUID()
      if keychainId == nil || storeId == nil { self.setDeviceIdentifier(id) }
      return id.uuidString
    }

    /// Remove the unique device identifier from all stores.
    open func resetDeviceIdentifier() {
      self.store.removeObject(forKey: key)
      self.keychainService.removeObject(for: key)
    }

    /// Write a unique device identifier to all stores.
    open func setDeviceIdentifier(_ id: LUUID) {
      self.store.set(id, forKey: key)
      self.keychainService.set(id.uuidString, for: key)
    }
  }

  extension DeviceIdentifier {
    var key: String { "com.swift.deviceidentifier" }
  }

  public extension Bundle {
    /// Get the bundle build number string, e.g. `123`.
    var buildNumber: String {
      let key = String(kCFBundleVersionKey)
      let version = infoDictionary?[key] as? String
      return version ?? ""
    }

    /// Get the bundle display name, if any.
    var displayName: String {
      infoDictionary?["CFBundleDisplayName"] as? String ?? "-"
    }

    /// Get the bundle version number string, e.g. `1.2.3`.
    var versionNumber: String {
      let key = "CFBundleShortVersionString"
      let version = infoDictionary?[key] as? String
      return version ?? "0.0.0"
    }
  }
#else
  import AppKit
#endif

// MARK: - SwiftPreviewInspector

/// This protocol can be implemented by types that can check if
/// the code is running in a SwiftUI preview.
///
/// The protocol is implemented by `ProcessInfo`.
public protocol SwiftPreviewInspector {
  /// Whether or not the code runs in a SwiftUI preview.
  var isSwiftUIPreview: Bool { get }
}

///
public extension SwiftPreviewInspector {
  /// Whether or not the code runs in a SwiftUI preview.
  var isSwiftUIPreview: Bool {
    ProcessInfo.isSwiftUIPreview
  }
}

extension ProcessInfo: SwiftPreviewInspector {}
public extension ProcessInfo {
  /// Whether or not the code runs in a SwiftUI preview.
  var isSwiftUIPreview: Bool {
    environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  }

  /// Whether or not the code runs in a SwiftUI preview.
  static var isSwiftUIPreview: Bool {
    processInfo.isSwiftUIPreview
  }
}
