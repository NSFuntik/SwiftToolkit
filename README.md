# SwiftToolkit

A comprehensive SwiftUI toolkit for iOS and macOS development.

## Modules

- **Core**: Core functionality and extensions
- **Foundation**: Foundation extensions and utilities
- **UI**: SwiftUI components and utilities
- **Coordinator**: Navigation coordination system
- **Feedback**: Haptic, audio, and visual feedback
- **STCoding**: Advanced encoding and decoding
- **DI**: Dependency injection system
- **Logger**: Logging system with filtering
- **SFSymbols**: Type-safe SF Symbols integration

## Installation

Add this to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/NSFuntik/SwiftToolkit.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            // Add complete umbrella module
            
            .product(name: "SwiftToolkit", package: "SwiftToolkit"),
            
            // Add specific module
            
            .product(name: "STCore", package: "SwiftToolkit"),
            .product(name: "UI", package: "SwiftToolkit"),
            .product(name: "Coordinator", package: "SwiftToolkit"),
            .product(name: "Feedback", package: "SwiftToolkit"),
            .product(name: "STCoding", package: "SwiftToolkit"),
            .product(name: "DI", package: "SwiftToolkit"),
            .product(name: "Logger", package: "SwiftToolkit"),
            .product(name: "SFSymbols", package: "SwiftToolkit")
        ]
    )
]
```


## Module-Specific Usage

Each module has its own README with detailed usage instructions:

- [STFoundation](Sources/STFoundation/README.md)
- [Core](Sources/Core/README.md)
- [UI](Sources/UI/README.md)
- [Coordinator](Sources/Coordinator/README.md)
- [Feedback](Sources/Feedback/README.md)
- [STCoding](Sources/STCoding/README.md)
- [DI](Sources/DI/README.md)
- [Logger](Sources/Logger/README.md)
- [SFSymbols](Sources/SFSymbols/README.md)

## Requirements

- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- watchOS 8.0+
- Swift 5.5+

## License


