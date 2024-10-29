
import Combine
import SwiftUI

#if os(iOS)

  /// Provides access to the device orientation manager in the environment values.
  public extension EnvironmentValues {
    /// The orientation manager for tracking device orientation changes.
    var orientation: OrientationManager {
      get { self[OrientationKey.self] }
      set { self[OrientationKey.self] = newValue }
    }
  }

  /// Defines a key to use a shared instance of `OrientationManager` in environment values.
  public struct OrientationKey: EnvironmentKey {
    /// The default value for the orientation key, which is the shared orientation manager.
    public static var defaultValue: OrientationManager = .shared
  }

  /// Provides additional functionality for the `UIDeviceOrientation` type.
  public extension UIDeviceOrientation {
    /// Determines which edge is associated with the notch side based on the device orientation.
    var notchSide: Edge.Set {
      switch self {
      case .landscapeLeft:
        return .leading
      case .landscapeRight:
        return .trailing
      default:
        return .top
      }
    }
  }

  /// Manages the device orientation and observes changes in orientation.
  public final class OrientationManager: Observable {
    /// The current type of device orientation.
    public var type: UIDeviceOrientation = .unknown
    private var cancellables: Set<AnyCancellable> = []
    /// A shared instance of the `OrientationManager`.
    public static let shared = OrientationManager()
    /// Initializes the orientation manager, setting up the current orientation and observing changes.
    private init() {
      guard let scene = UIApplication.shared.connectedScenes.first,
            let sceneDelegate = scene as? UIWindowScene else { return }
      let orientation = sceneDelegate.interfaceOrientation
      switch orientation {
      case .portrait: type = .portrait
      case .portraitUpsideDown: type = .portraitUpsideDown
      case .landscapeLeft: type = .landscapeLeft
      case .landscapeRight: type = .landscapeRight
      default: type = .unknown
      }
      UIDevice.current.beginGeneratingDeviceOrientationNotifications()
      NotificationCenter.default
        .publisher(for: UIDevice.orientationDidChangeNotification)
        .sink { _ in
          Task { @MainActor in
            self.type = UIDevice.current.orientation
          }
        }
        .store(in: &cancellables)
    }
  }

#endif
