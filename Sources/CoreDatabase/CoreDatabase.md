# CoreDatabase

## Overview

CoreDatabase is a powerful, type-safe Swift framework for CoreData and CloudKit integration, designed to simplify database operations with modern Swift features.

## 🚀 Key Features

- **Async/Await Support**: Seamless asynchronous database operations
- **Type-Safe Object Identifiers**: Robust `ObjectId` wrapper
- **CloudKit Sharing**: Built-in support for cross-device synchronization
- **Comprehensive Logging**: Advanced error tracking and reporting
- **Flexible Store Configurations**: Local, cloud, and hybrid storage options
- **Combine-Based Change Tracking**: Reactive database observation
- **Automatic Merging**: Intelligent change management across contexts

## Requirements

- iOS 15.0+
- macOS 12.0+
- Swift 5.5+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
.package(url: "https://github.com/NSFuntik/SwiftToolkit.git", from: "1.0.0")
]
```

## Quick Start

### Basic Database Initialization

```swift
// Standard local database
let database = Database()

// With custom store configuration
let database = Database(
storeDescriptions: [.localData()],
modelBundle: .module
)

// CloudKit-enabled database
let database = Database(
storeDescriptions: [.cloudWithShare()],
modelBundle: .module
)
```

### Async Operations

```swift
// Edit operation
try await database.edit { ctx in
let user = User(context: ctx)
user.name = "John Doe"
}

// Fetch operation
let users = try await database.fetch { ctx in
User.all(ctx)
}
```

### CloudKit Sharing

```swift
// Create a share
let share = try await database.makeShare(user)

// Accept a share
try await database.accept(shareMetadata)
```

### Change Observation

```swift
// Observe changes to a specific entity
User.didChange(database)
.sink { change in
print("Inserted: \(change.inserted)")
print("Updated: \(change.updated)")
print("Deleted: \(change.deleted)")
}
```

## Advanced Features

### Custom Logging

```swift
class CustomLogger: DatabaseLogger {
func logError(_ error: Error, context: [String: Any]?) {
// Custom error handling
}
}
```

### Persistent Store Configurations

```swift
let storeDescriptions = [
NSPersistentStoreDescription.localData(),
NSPersistentStoreDescription.cloudWithShare()
]
let database = Database(storeDescriptions: storeDescriptions)
```

## Error Handling

CoreDatabase provides comprehensive error handling through the `DatabaseLogger` protocol and `DatabaseError` enum.

## Performance Considerations

- Automatic context management
- Efficient background processing
- Intelligent change tracking

## Limitations

- Requires iOS 15.0+ due to async/await and modern CoreData features
- CloudKit sharing requires Apple ecosystem

