# DI (Dependency Injection)

Lightweight dependency injection system.

## Features

- Property wrapper based injection
- Singleton management
- Scope control
- Type-safe dependencies

## Usage

```swift
import DI

// Register a dependency
DI.register { NetworkService() }

// Inject a dependency
@Injected var network: NetworkService

// Scoped registration
DI.register(.singleton) { DatabaseService() }
```

## DI Namespace

The `DI` namespace provides a comprehensive dependency injection system for Swift applications, particularly focused on SwiftUI integration.

### Key<Value>

```swift
public struct Key<Value>: Hashable, Sendable
```

A type-safe key for storing and retrieving services in the DI container.

#### Methods

- `init()` - Creates a new key instance for service identification.

### Static<Service>

```swift
@propertyWrapper
public struct Static<Service>
```

A property wrapper providing static access to services in the DI container.

#### Properties

- `wrappedValue: Service` - The resolved service instance
- `projectedValue: Static<Service>` - The property wrapper instance itself

#### Methods

- `init(_ key: Key<Service>)` - Initializes the wrapper with a key
- `init<ServiceContainer>(_ key: Key<ServiceContainer>, _ keyPath: KeyPath<ServiceContainer, Service>)` - Initializes the wrapper with a key and keypath for nested service access
- `replace(_ service: Service)` - Replaces the current service instance with a new one

### Observed<Service>

```swift
@propertyWrapper
public struct Observed<Service>: DynamicProperty
```

A property wrapper for SwiftUI views to observe changes in services.

#### Properties

- `wrappedValue: Service` - The resolved service instance
- `projectedValue: Binding<Service>` - A binding to the service

#### Methods

- `init(wrappedValue value: Service)` - Initializes with a direct service value
- `init(_ key: Key<Service>)` - Initializes with a service key
- `init<ServiceContainer>(_ key: Key<ServiceContainer>, _ keyPath: KeyPath<ServiceContainer, Service>)` - Initializes with a key and keypath

### RePublished<Service>

```swift
@propertyWrapper
public final class RePublished<Service>
```

A property wrapper for republishing service changes in ObservableObjects.

#### Methods

- `init(wrappedValue value: Service)` - Initializes with a direct service value
- `init(_ key: Key<Service>)` - Initializes with a service key
- `init<ServiceContainer>(_ key: Key<ServiceContainer>, _ keyPath: KeyPath<ServiceContainer, Service>)` - Initializes with a key and keypath
- `replace(_ service: Service)` - Replaces the current service instance

### Container

```swift
public final class Container
```

The singleton container managing all service instances.

#### Static Methods

- `register<Service>(_ key: Key<Service>, _ make: () -> Service)` - Registers a service using a factory closure
- `register<Service>(_ key: Key<Service>, _ service: Service)` - Registers a pre-existing service instance
- `resolve<Service>(_ key: Key<Service>) -> Service` - Resolves a service instance
- `resolveObservable<Service>(_ key: Key<Service>) -> ObservableObjectWrapper<Service>` - Resolves a service as an observable wrapper

## ObservableObjectWrapper

```swift
public final class ObservableObjectWrapper<Value>: ObservableObject
```

A wrapper that provides ObservableObject conformance for any type.

#### Properties

- `observed: Value` - The wrapped value

#### Methods

- `init(_ observable: Value)` - Initializes the wrapper with a value
