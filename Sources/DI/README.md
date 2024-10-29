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
