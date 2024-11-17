# SwiftToolkit
![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)
![Swift Version](https://img.shields.io/badge/swift-5.5-orange.svg)
![Platforms](https://img.shields.io/badge/platforms-iOS%2015%2B%20%7C%20macOS%2012%2B%20%7C%20tvOS%2015%2B%20%7C%20macCatalyst%2015%2B-blue.svg)
![License](https://img.shields.io/badge/license-Unlicense-blue.svg)

A comprehensive SwiftUI toolkit for iOS and macOS development.

## Modules

- **[Core](Sources/Core/README.md)**: Core functionality and extensions
- **[Foundation](Sources/STFoundation/README.md)**: Foundation extensions and utilities
- **[UI](Sources/UI/README.md)**: SwiftUI components and utilities
- **[Coordinator](Sources/Coordinator/README.md)**: Navigation coordination system
- **[Feedback](Sources/Feedback/README.md)**: Haptic, audio, and visual feedback
- **[STCoding](Sources/STCoding/README.md)**: Advanced encoding and decoding
- **[DI](Sources/DI/README.md)**: Dependency injection system
- **[Logger](Sources/Logger/README.md)**: Logging system with filtering
- **[SFSymbols](Sources/SFSymbols/README.md)**: Type-safe SF Symbols integration

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
            
            .product(name: "Core", package: "SwiftToolkit"),
            .product(name: "UI", package: "SwiftToolkit"),
            .product(name: "Coordinator", package: "SwiftToolkit"),
            .product(name: "Feedback", package: "SwiftToolkit"),
            .product(name: "Coding", package: "SwiftToolkit"),
            .product(name: "DI", package: "SwiftToolkit"),
            .product(name: "Logger", package: "SwiftToolkit"),
            .product(name: "SFSymbols", package: "SwiftToolkit"),
            .product(name: "CoreDatabase", package: "SwiftToolkit")

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
- [Coding](Sources/Coding/README.md)
- [DI](Sources/DI/README.md)
- [Logger](Sources/Logger/README.md)
- [SFSymbols](Sources/SFSymbols/README.md)
- [CoreDatabase](Sources/CoreDatabase/CoreDatabase.md)
## Requirements

- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- Swift 5.5+

## License

This project is released into the public domain under The Unlicense.

See the [LICENSE](LICENSE) file for more details.
