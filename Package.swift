// swift-tools-version: 5.5
import PackageDescription

let package = Package(
  name: "SwiftToolkit",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8),
    .macCatalyst(.v15),
  ],
  products: [
    // Core modules
    .library(name: "STCore", targets: ["Core"]),

    // Feature modules
    .library(name: "UI", targets: ["UI"]),
    .library(name: "Coordinator", targets: ["Coordinator"]),
    .library(name: "Feedback", targets: ["Feedback"]),
    .library(name: "STCoding", targets: ["STCoding"]),
    .library(name: "DI", targets: ["DI"]),
    .library(name: "Logger", targets: ["Logger"]),
    .library(name: "SFSymbols", targets: ["SFSymbols"]),

    // Umbrella module
    .library(
      name: "SwiftToolkit",
      type: .dynamic,
      targets: ["SwiftToolkit"]),
  ],
  targets: [
    // Core targets
    .target(
      name: "STFoundation"),

    .target(name: "Core", dependencies: ["STFoundation"]),
    // Feature targets
    .target(name: "UI", dependencies: ["Core", "Feedback", "SFSymbols"]),
    .target(name: "Coordinator"),
    .target(name: "Feedback", dependencies: ["Core"]),
    .target(name: "STCoding", dependencies: ["Core"]),
    .target(name: "DI"),
    .target(name: "Logger", dependencies: ["Core"]),
    .target(name: "SFSymbols", dependencies: ["Core", "DI"]),

    // Umbrella target
    .target(name: "SwiftToolkit",
            dependencies: [
              "Core",
              "UI",
              "Coordinator",
              "STCoding",
              "DI",
              "Logger",
            ]),

  ])
