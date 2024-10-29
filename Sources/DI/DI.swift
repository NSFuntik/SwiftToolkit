import SwiftUI
import Foundation
@_exported import Combine

// MARK: - DI

/// A namespace for the dependency injection container that provides a comprehensive dependency management system.
///
/// The DI system supports three main types of dependency injection through property wrappers:
/// - `@DI.Static` for simple value dependencies
/// - `@DI.Observed` for use in ``SwiftUI.View`` dependencies
/// - `@DI.RePublished` for ObservableObject dependencies
///
/// Example of defining keys:
/// ```swift
/// extension DI {
///     static let network = Key<any Network>()
///     static let dataManager = Key<any DataManager>()
///     static let settings = Key<any Settings>()
/// }
/// ```
///
/// Example of registering services:
/// ```swift
/// extension DI.Container {
///     static func setup() {
///         register(DI.network, NetworkImp())
///         register(DI.dataManager, DataManagerImp())
///         register(DI.settings, SettingsImp())
///     }
/// }
/// ```
public enum DI {
  /// A property wrapper that provides a reference to a service in DI.Container.
  /// This wrapper does not increase the size of a struct and is suitable for static service references.
  ///
  /// Example usage:
  /// ```swift
  /// class ServiceManager {
  ///     @DI.Static(DI.network) var network
  ///     @DI.Static(DI.settings, \.configuration) var config
  /// }
  /// ```
  @propertyWrapper
  public struct Static<Service> {
    /// The resolved service instance
    public let wrappedValue: Service
    private let key: Key<Service>?

    /// Initializes the wrapper with a service key
    /// - Parameter key: The key used to identify and resolve the service
    public init(_ key: Key<Service>) {
      self.key = key
      wrappedValue = Container.resolve(key)
    }

    /// Initializes the wrapper with a service container key and keypath for nested access
    /// - Parameters:
    ///   - key: The key used to identify and resolve the service container
    ///   - keyPath: The keypath to access the nested service within the container
    public init<ServiceContainer>(
      _ key: Key<ServiceContainer>,
      _ keyPath: KeyPath<ServiceContainer, Service>) {
      self.key = nil
      wrappedValue = Container.resolveObservable(key).observed[keyPath: keyPath]
    }

    /// Provides access to the property wrapper instance
    public var projectedValue: Static<Service> { self }

    /// Replaces the current service instance with a new one
    /// - Parameter service: The new service instance to register
    public func replace(_ service: Service) {
      if let key {
        Container.register(key, service)
      }
    }
  }

  /// A property wrapper that provides a reference to an `any ObservableObject` service in `DI.Container`.
  /// Designed specifically for SwiftUI views, this wrapper triggers view updates when the service changes.
  ///
  /// Example usage:
  /// ```swift
  /// struct UserProfileView: View {
  ///     @DI.Observed(DI.userManager) var userManager
  ///
  ///     var body: some View {
  ///         Text(userManager.username)
  ///     }
  /// }
  /// ```
  @propertyWrapper
  public struct Observed<Service>: DynamicProperty {
    @StateObject private var wrapper: ObservableObjectWrapper<Service>

    /// The resolved service instance
    public var wrappedValue: Service { wrapper.observed }

    /// Initializes the wrapper with a direct service value
    /// - Parameter value: The service instance to wrap
    public init(wrappedValue value: Service) {
      _wrapper = .init(wrappedValue: .init(value))
    }

    /// Initializes the wrapper with a service key
    /// - Parameter key: The key used to identify and resolve the service
    public init(_ key: Key<Service>) {
      _wrapper = .init(wrappedValue: Container.resolveObservable(key))
    }

    /// Initializes the wrapper with a service container key and keypath for nested access
    /// - Parameters:
    ///   - key: The key used to identify and resolve the service container
    ///   - keyPath: The keypath to access the nested service within the container
    public init<ServiceContainer>(
      _ key: Key<ServiceContainer>,
      _ keyPath: KeyPath<ServiceContainer, Service>) {
      _wrapper = .init(wrappedValue: .init(Container.resolveObservable(key).observed[keyPath: keyPath]))
    }

    /// Provides a binding to the service instance
    public var projectedValue: Binding<Service> { $wrapper.observed }
  }

  /// A property wrapper that provides a reference to an `any ObservableObject` service in `DI.Container`.
  /// Designed for use in other `ObservableObjects`, this wrapper triggers `objectWillChange` of the enclosing instance
  /// when the service changes.
  ///
  /// Example usage:
  /// ```swift
  /// class ViewModel: ObservableObject {
  ///     @DI.RePublished(DI.userManager) var userManager
  ///     @DI.RePublished(DI.appState, \.settings) var settings
  /// }
  /// ```
  @propertyWrapper
  public final class RePublished<Service> {
    public static subscript<T: ObservableObject>(
      _enclosingInstance instance: T,
      wrapped _: ReferenceWritableKeyPath<T, Service>,
      storage storageKeyPath: ReferenceWritableKeyPath<T, RePublished>) -> Service {
      get {
        if instance[keyPath: storageKeyPath].observer == nil {
          instance[keyPath: storageKeyPath].setupObserver(instance)
        }
        return instance[keyPath: storageKeyPath].value
      }
      set {}
    }

    private func setupObserver<T: ObservableObject>(_ instance: T) {
      observer = ((value as? any ObservableObject)?.sink { [weak instance] in
        (instance?.objectWillChange as? any Publisher as? ObservableObjectPublisher)?.send()
      })
    }

    private var observer: AnyCancellable?

    @available(*, unavailable, message: "This property wrapper can only be applied to classes")
    public var wrappedValue: Service {
      get { fatalError() }
      set { fatalError() }
    }

    private var value: Service
    private let key: Key<Service>?

    /// Initializes the wrapper with a direct service value
    /// - Parameter value: The service instance to wrap
    public init(wrappedValue value: Service) {
      key = nil
      self.value = value
    }

    /// Initializes the wrapper with a service container key and keypath for nested access
    /// - Parameters:
    ///   - key: The key used to identify and resolve the service container
    ///   - keyPath: The keypath to access the nested service within the container
    public init<ServiceContainer>(
      _ key: Key<ServiceContainer>,
      _ keyPath: KeyPath<ServiceContainer, Service>) {
      self.key = nil
      value = Container.resolveObservable(key).observed[keyPath: keyPath]
    }

    /// Initializes the wrapper with a service key
    /// - Parameter key: The key used to identify and resolve the service
    public init(_ key: Key<Service>) {
      self.key = key
      value = Container.resolve(key)
    }

    /// Provides access to the property wrapper instance
    public var projectedValue: RePublished<Service> { self }

    /// Replaces the current service instance with a new one
    /// - Parameter service: The new service instance to register
    public func replace(_ service: Service) {
      if let key = projectedValue.key {
        Container.register(key, service)
      }
      observer = nil
      value = service
    }
  }
}

/// A key for *storing* and *retrieving* services in the `DI.Container`.
/// Keys are type-safe and unique, ensuring that services are correctly matched with their types.
///
/// Example of defining keys:
/// ```swift
/// extension DI {
///     static let networkService = Key<any NetworkService>()
///     static let userManager = Key<any UserManager>()
/// }
/// ```
public extension DI {
  struct Key<Value>: Hashable, Sendable {
    private let id = UUID()

    /// Creates a new key instance for service identification
    public init() {}
  }

  /// A *singleton* container for managing service instances with thread-safe access.
  /// The container supports registration and resolution of services, with automatic
  /// replacement of existing services when registering with the same key.
  final class Container {
    /// The singleton instance of the service container
    fileprivate static let current = Container()

    /// Lock for thread-safe access to storage
    private var lock = pthread_rwlock_t()

    /// Storage for registered services, using the hash value of the key for indexing
    private var storage: [Int: Any] = [:]

    public init() {
      pthread_rwlock_init(&lock, nil)
    }

    /// Registers a new service with a specified key using a factory closure
    /// - Parameters:
    ///   - key: The key used to identify the service
    ///   - make: A closure that produces the service instance
    public static func register<Service>(
      _ key: Key<Service>,
      _ make: () -> Service) {
      let service = make()
      pthread_rwlock_wrlock(&current.lock)
      current.storage[key.hashValue] = ObservableObjectWrapper(service)
      pthread_rwlock_unlock(&current.lock)
    }

    /// Registers a pre-existing service instance with a specified key
    /// - Parameters:
    ///   - key: The key used to identify the service
    ///   - service: The service instance to register
    public static func register<Service>(
      _ key: Key<Service>,
      _ service: Service) {
      register(key) { service }
    }

    /// Resolves a service as an ObservableObjectWrapper for the specified key
    /// - Parameter key: The key used to identify the service
    /// - Returns: An ObservableObjectWrapper containing the requested service
    /// - Note: This method is thread-safe and can be called from multiple threads
    public static func resolveObservable<Service>(_ key: Key<Service>) -> ObservableObjectWrapper<Service> {
      pthread_rwlock_rdlock(&current.lock)
      let result = current.storage[key.hashValue] as! ObservableObjectWrapper<Service>
      pthread_rwlock_unlock(&current.lock)
      return result
    }

    /// Resolves a service instance for the specified key
    /// - Parameter key: The key used to identify the service
    /// - Returns: The requested service instance
    /// - Note: This method is thread-safe and can be called from multiple threads
    public static func resolve<Service>(_ key: Key<Service>) -> Service {
      resolveObservable(key).observed
    }

    deinit {
      pthread_rwlock_destroy(&lock)
    }
  }
}

// MARK: - ObservableObjectWrapper

/// ObservableObject wrapper with type erased input.
/// This wrapper provides ObservableObject conformance for any type and forwards updates
/// from the wrapped instance to its own objectWillChange publisher.
///
/// Example usage:
/// ```swift
/// let wrapper = ObservableObjectWrapper(myService)
/// ```
public final class ObservableObjectWrapper<Value>: ObservableObject {
  /// The wrapped value
  public fileprivate(set) var observed: Value
  private var observer: AnyCancellable?

  /// Creates a new wrapper instance
  /// - Parameter observable: The value to wrap
  public init(_ observable: Value) {
    observed = observable

    observer = (observable as? any ObservableObject)?.sink { [weak self] in
      self?.objectWillChange.send()
    }
  }
}

private extension ObservableObject {
  /// Helper function to subscribe to objectWillChange
  /// - Parameter closure: The closure to execute when the object changes
  /// - Returns: A cancellable subscription
  func sink(_ closure: @escaping () -> Void) -> AnyCancellable {
    objectWillChange.sink { _ in closure() }
  }
}

// MARK: - Sendable Conformance

extension DI.Static: Sendable where Service: Sendable {}
