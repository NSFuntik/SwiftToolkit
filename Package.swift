// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "SwiftToolkit",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .macCatalyst(.v15)
  ],
  products: [
    // Core modules
    .library(name: "Core", targets: ["Core"]),

    // Feature modules
    .library(name: "UI", targets: ["UI"]),
    .library(name: "Coordinator", targets: ["Coordinator"]),
    .library(name: "Feedback", targets: ["Feedback"]),
    .library(name: "Coding", targets: ["Coding"]),
    .library(name: "DI", targets: ["DI"]),
    .library(name: "Logger", targets: ["Logger"]),
    .library(name: "SFSymbols", targets: ["SFSymbols"]),
    .library(name: "CoreDatabase", targets: ["CoreDatabase"]),

    // Umbrella module
    .library(
      name: "SwiftToolkit",
      type: .dynamic,
      targets: ["SwiftToolkit"])
  ],
  targets: [
    // Core targets
    .target(name: "STFoundation", exclude: ["README.md"]),
    .target(name: "Core", dependencies: ["STFoundation"], exclude: ["README.md"]),
    // Feature targets
    .target(name: "UI", dependencies: ["Core", "Feedback", "SFSymbols"], exclude: ["README.md"]),
    .target(name: "Coordinator", exclude: ["README.md"]),
    .target(name: "Feedback", dependencies: ["Core"], exclude: ["README.md"]),
    .target(name: "Coding", dependencies: ["Core"], exclude: ["README.md"]),
    .target(name: "DI", exclude: ["README.md"]),
    .target(name: "Logger", dependencies: ["Core"], exclude: ["README.md"]),
    .target(name: "SFSymbols", dependencies: ["Core", "DI"], exclude: ["README.md"]),
    .target(name: "CoreDatabase", dependencies: ["Core"], exclude: ["CoreDatabase.md"]),

    // Umbrella target
    .target(
      name: "SwiftToolkit",
      dependencies: [
        "Core",
        "UI",
        "Coordinator",
        "Coding",
        "DI",
        "Logger",
        "CoreDatabase"
      ]
    )
  ],
  swiftLanguageVersions: [.v5]
)
