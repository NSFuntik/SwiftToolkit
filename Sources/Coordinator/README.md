# SwiftUI Coordinator

A powerful and flexible coordination system for managing navigation and modal presentations in SwiftUI applications.

## Features

- Type-safe navigation coordination
- Modal presentation management
- Alert handling
- Memory-safe coordinator references
- Support for nested navigation flows
- iOS 16.0+ support

## Basic Usage

### Creating a Coordinator

To create a basic coordinator that handles both navigation and modal presentations:

```swift
final class SomeCoordinator: NavigationModalCoordinator {
    enum Screen: ScreenProtocol {
        case screen1
        case screen2
        case screen3
    }

    func destination(for screen: Screen) -> some View {
        switch screen {
            case .screen1: Screen1View()
            case .screen2: Screen2View()
            case .screen3: Screen3View()
        }
    }

    enum ModalFlow: ModalProtocol {
        case modalScreen1
        case modalFlow(ChildCoordinator = .init())
    }

    func destination(for flow: ModalFlow) -> some View {
        switch flow {
            case .modalScreen1: Modal1View()
            case .modalFlow(let coordinator): coordinator.view(for: .rootScreen)
        }
    }
}
```

### Using the Coordinator

#### Setting up the Root View

```swift
coordinator.view(for: .screen1)
```

#### Navigation

Push a new view onto the navigation stack:
```swift
coordinator.present(.screen1)
```

Pop the top view:
```swift
coordinator.pop()
```

Pop to root:
```swift
coordinator.popToRoot()
```

#### Modal Presentation

Present a modal view:
```swift
coordinator.present(.modalFlow())
```

Dismiss the current modal:
```swift
coordinator.dismiss()
```

#### Alerts

Show a simple alert:
```swift
coordinator.alert("Title", message: "Alert message")
```

Show an alert with custom actions:
```swift
coordinator.alert("Title") {
    Button("OK") { /* action */ }
    Button("Cancel", role: .cancel) { /* action */ }
} message: {
    Text("Custom alert message")
}
```

## Advanced Features

### Modal Presentation Styles

Three presentation styles are available:

- `.sheet`: Partial screen cover (default)
- `.cover`: Full screen cover
- `.overlay`: Overlay on top of current navigation

```swift
enum ModalFlow: ModalProtocol {
    case settings
    case profile(User)
    
    var style: ModalStyle {
        switch self {
        case .settings: return .sheet
        case .profile: return .cover
        }
    }
}
```

### Presentation Resolution

When presenting modals, you can specify how to handle existing presentations:

```swift
// Present over current modal
coordinator.present(.settings, resolve: .overAll)

// Dismiss current and present new modal
coordinator.present(.settings, resolve: .replaceCurrent)
```

### Nested Navigation

You can create nested navigation flows by embedding child coordinators:

```swift
enum ModalFlow: ModalProtocol {
    case childFlow(ChildCoordinator = .init())
}
```

### Custom Coordinators

For simple flows, you can use `CustomCoordinator`:

```swift
final class SimpleCoordinator: CustomCoordinator {
    func destination() -> some View {
        Text("Simple View")
    }
}
```

## Best Practices

1. Define your screens and modal flows as enums conforming to `ScreenProtocol` and `ModalProtocol`
2. Keep coordinator implementations focused and single-responsibility
3. Use child coordinators for complex nested flows
4. Consider modal presentation styles based on your use case
5. Handle memory management using the provided weak reference system

## Requirements

- iOS 16.0+
- Swift 5.5+
- SwiftUI
