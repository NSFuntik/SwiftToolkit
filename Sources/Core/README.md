# Core

Core functionality and extensions for SwiftToolkit.

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
   - [Extensions](#extensions)
     - [Binding Extensions](#binding-extensions)
     - [Date Formatter Extensions](#date-formatter-extensions)
     - [Image Extensions](#image-extensions)
     - [NSObject Extensions](#nsobject--foundation-extensions)
     - [Sequence Extensions](#sequence-extensions)
     - [String Extensions](#string-extensions)
     - [URL Extensions](#url-extensions)
     - [View Extensions](#view-extensions)
     - [Font Extensions](#font-extensions)
   - [Utilities](#utilities)
     - [AsyncPassthroughSubject](#asyncpassthroughsubject)
     - [ErrorAlert](#erroralert)
     - [LUUID](#luuid)
     - [MIMEType](#mimetype)
     - [Observable](#observable)
3. [Installation](#installation)
4. [Usage Examples](#usage-examples)
   - [Error Handling](#error-handling-with-erroralert)
   - [Event Handling](#using-asyncpassthroughsubject-for-event-handling)
   - [MIME Types](#mime-type-handling)
   - [Observable Pattern](#observable-environment-objects)
5. [Advanced Features](#advanced-features)
   - [Task Extensions](#task-extensions)
6. [Best Practices](#best-practices)
   - [Error Handling](#error-handling-1)
   - [Asynchronous Events](#asynchronous-events)
   - [MIME Types](#mime-types-1)
   - [Observable Pattern](#observable-pattern-1)

## Overview

### Extensions
- **Binding Extensions**: SwiftUI binding utilities and optional value handling
- **Date Formatter Extensions**: Date formatting, parsing, and manipulation
- **Image Extensions**: Image processing, scaling, and conversion utilities
- **NSObject Extensions**: Core Foundation and lifecycle management
- **Sequence Extensions**: Collection operations and transformations
- **String Extensions**: Text manipulation and pattern matching
- **URL Extensions**: URL construction and file management
- **View Extensions**: SwiftUI view modifiers and utilities
- **Font Extensions**: Typography and font management

### Utilities

- **AsyncPassthroughSubject**: Async event handling and observation
- **ErrorAlert**: User-facing error presentation system
- **LUUID**: Standardized **UUID RFC 4122** version of native `UUID`
- **MIMEType**: File type detection and handling
- **Observable**: Enhanced ObservableObject implementation

## Features

### Utilities

#### AsyncPassthroughSubject

A Swift Concurrency-based implementation of a passthrough subject for handling asynchronous events.

```swift
// Create a subject
let subject = AsyncPassthroughSubject<String>()

// Subscribe to notifications
let stream = subject.notifications()
Task {
    for await element in stream {
        print("Received:", element)
    }
}

// Send elements
subject.send("Hello")
```

#### ErrorAlert
A comprehensive error handling and alert presentation system.

```swift
// Define custom error
struct CustomError: ErrorAlertConvertible {
    var errorTitle: String { "Error Occurred" }
    var errorMessage: String { "Something went wrong" }
    var errorButtonText: String { "OK" }
}

// Use in SwiftUI views
struct ContentView: ErrorAlerter {
    @StateObject private var alertContext = AlertContext()
    
    func performOperation() {
        tryWithErrorAlert {
            try await riskyOperation()
        }
    }
}
```

#### LUUID
Standardized **UUID RFC 4122** version of native `UUID` implementation with additional features and safety checks.

```swift
// Create a new UUID
let id = LUUID()

// Create from string
if let uuid = LUUID(uuidString: "e621e1f8-c36c-495a-93fc-0c247a3e6e5f") {
    print(uuid.uuidString)
}

// Check for null UUID
if !id.isEmpty() {
    // Use valid UUID
}
```

#### MIMEType
Comprehensive MIME type handling with support for various file formats.

```swift
// Get MIME type for file extension
let mimeType = try MIMEType.from(pathExtension: "jpg")
print(mimeType.id) // "image/jpeg"

// Check specific types
switch mimeType {
case .image(let format):
    print("Image format:", format)
case .video(let format):
    print("Video format:", format)
default:
    break
}
```

#### Observable
Enhanced ObservableObject protocol with environment support.

```swift
class MyViewModel: Observable {
    @Published var value = 0
}

struct MyView: View {
    var body: some View {
        Text("Hello")
            .environment(MyViewModel())
    }
}
```

### Extensions

#### Binding Extensions
SwiftUI binding utilities:

```swift
// Unwrap optional bindings with default value
@State var optionalText: String?
TextField("Enter text", text: $optionalText.unwrapped(""))
```

#### Date Formatter Extensions
Date formatting and manipulation:

```swift
// ISO8601 Formatting
let isoFormatter = ISO8601DateFormatter.full
let dateString = isoFormatter.string(from: .now)

// Custom Date Formatting
let formatter = DateFormatter(dateFormat: "yyyy-MM-dd")
let timeString = DateFormatter.timeString(3665) // "01:01:05"

// Date Initialization
let date = try Date(string: "2024-03-15", format: "yyyy-MM-dd")

// Date Comparison
let days = date.distance(from: .now, only: .day)
let hasSameDay = date.hasSame(.day, as: .now)

// Timestamps
let timestamp = Date().timestamp
let currentTimestamp = Date.currentTimeStamp
```

#### NSObject & Foundation Extensions
Core functionality extensions:

```swift
// Main Actor Operations
runOnMainActor {
    // UI updates
}

asyncOnMainActor {
    // Async UI updates
}

// Optional Extensions
let optional: String? = "value"
optional.isSet   // true
optional.isNil   // false

// Wrapper Types
let wrapper = TypeWrapper(object: "value")

// File Handling
let file = File(url: fileURL)
print(file?.modificationDate)
print(file?.size)
```

#### Image Extensions

Image handling utilities:

```swift
#if canImport(UIKit)
// UIImage Extensions
let fixedImage = image.fixOrientation()
let scaledImage = image.scaleToFill(in: CGSize(width: 100, height: 100))
let resized = image.resized(withPercentage: 0.5)

// Data Conversion
let pngData = image.png
let jpgData = image.jpg(quality: 0.8)

// SwiftUI System Images
let icon = Image.system("star.fill")

#elseif canImport(AppKit)
// NSImage Extensions
let pngData = image.png()
let jpgData = image.jpg(quality: 0.8)
#endif
```

#### Sequence Extensions
Powerful extensions for collections and sequences:

```swift
// Optional Collection extensions
let array: [Int]? = [1, 2, 3]
array.isEmpty    // false
array.nonEmpty   // true

// Array extensions
let numbers = [1, 2, 3]
numbers.nilOrEmpty            // Returns array if not empty, nil if empty
numbers.lastIndex             // Quick access to last index
numbers.appending([4, 5, 6])  // Returns new array with appended elements

// Async operations
await items.asyncMap { item in 
    try await processItem(item)
}

// Grouping and unique operations
let items = ["a", "b", "a", "c"]
let unique = items.unique()
let grouped = items.grouped { $0.first! }
```

#### String Extensions
Rich text manipulation and formatting capabilities:

```swift
// Subscript access
let str = "Hello"
str[0]  // "H"

// Content checks
"Hello".hasContent        // true
"  ".hasTrimmedContent    // false
"".nilIfEmpty            // nil

// String manipulation
str.replacing("Hello", with: "Hi")
str.trimmed()
str.contains("ello", caseSensitive: false)

// Pattern matching
"123".matches(regex: "\\d+")  // true

// Formatting
phoneNumber.format(with: "+X (XXX) XXX XX XX")

// String measurements
#if canImport(UIKit)
text.width(withConstrainedWidth: 200, font: .systemFont(ofSize: 14))
text.numberOfLines(labelWidth: 200, font: .systemFont(ofSize: 14))
#endif

// String comparison
"hello".equals("Hello", caseSensitive: false)  // true
```

#### Device & Platform Extensions
Platform-specific utilities:

```swift
#if canImport(UIKit)
// Device information
UIDevice.isIPad
UIDevice.isIPhone
UIDevice.deviceId

// Bundle information
Bundle.main.buildNumber
Bundle.main.displayName
Bundle.main.versionNumber

// Preview detection
ProcessInfo.isSwiftUIPreview
#endif
```

#### URL Extensions
Enhanced URL handling:

```swift
// URL Components
var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
components?.setQueryItems(with: ["key": "value"])

// URL manipulation
url.appending(query: [URLQueryItem(name: "key", value: "value")])
url.append(path: "subpath")

// File attributes
url.fileSize
url.fileSizeStr
url.creationDate

// Common directories
URL.documents
URL.caches
URL.temporary
URL.applicationSupport
```

#### View Extensions
SwiftUI view enhancements:

```swift
// View modifications
view.embedInNavigation()
view.eraseToAnyView()

// Conditional modifiers
view.if(condition) { $0.padding() }
view.ifLet(optionalValue) { view, value in 
    view.overlay(Text(value))
}

// Frame and padding utilities
view.frame(box: 100)  // Square frame
view.padding(vertical: 10, horizontal: 20)

// Visibility control
view.isHidden(shouldHide)

#if canImport(UIKit)
// Adaptive colors
Color.adaptiveColor(withSeed: "unique-seed")

// UI enhancements
view.highlightEffect()
view.ignoreKeyboard()
view.vibrantForeground()
#endif
```

#### Font Extensions
Typography utilities:

```swift
// System font configuration
Font.system(.body, .default, .regular)
Font.system(.headline, .monospaced, .bold)
Font.system(.title, .rounded)
```

## Installation

Add SwiftToolkit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/username/SwiftToolkit.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "Core", package: "SwiftToolkit")
        ]
    )
]
```

## Usage Examples

### Error Handling with ErrorAlert

```swift
struct ContentView: View, ErrorAlerter {
    @StateObject private var alertContext = AlertContext()
    
    var body: some View {
        Button("Perform Action") {
            tryWithErrorAlert {
                try await performRiskyOperation()
            }
        }
        .alert(alertContext)
    }
}
```

### Using AsyncPassthroughSubject for Event Handling

```swift
class DataManager {
    let updates = AsyncPassthroughSubject<Data>()
    
    func startMonitoring() {
        Task {
            for await data in updates.notifications() {
                // Process updates
            }
        }
    }
    
    func updateData(_ data: Data) {
        updates.send(data)
    }
}
```

### MIME Type Handling

```swift
func handleFile(at url: URL) throws {
    let mimeType = try MIMEType.from(pathExtension: url.pathExtension)
    
    switch mimeType {
    case .image(let format):
        switch format {
        case .jpeg, .png:
            // Handle image
        default:
            throw TypeError.invalidMimeType(type: format.rawValue)
        }
    case .video(let format):
        // Handle video
    default:
        // Handle other types
    }
}
```

### Observable Environment Objects

```swift
class UserSettings: Observable {
    @Published var theme: Theme = .light
    @Published var fontSize: CGFloat = 14
}

struct SettingsView: View {
    @ObservedObject var settings: UserSettings
    
    var body: some View {
        Form {
            Picker("Theme", selection: $settings.theme) {
                ForEach(Theme.allCases) { theme in
                    Text(theme.name).tag(theme)
                }
            }
            Slider(value: $settings.fontSize, in: 12...24)
        }
        .environment(settings)
    }
}
```

## Advanced Features

### Task Extensions

```swift
// Wait for multiple tasks to complete
let tasks = [
    Task { try await operation1() },
    Task { try await operation2() }
]

let results = try await tasks.first!.whenAll(tasks: tasks)
```

## Best Practices

1. **Error Handling**
   - Use `ErrorAlertConvertible` for user-facing errors
   - Implement custom error types for specific domains
   - Use `tryWithErrorAlert` for async operations

2. **Asynchronous Events**
   - Prefer `AsyncPassthroughSubject` over traditional Combine subjects
   - Use structured concurrency with async/await
   - Handle task cancellation appropriately

3. **MIME Types**
   - Use the type-safe `MIMEType` enum instead of raw strings
   - Handle unknown types gracefully
   - Validate file extensions before processing

4. **Observable Pattern**
   - Use `Observable` protocol for view models
   - Leverage environment for dependency injection
   - Keep observable objects focused and minimal

## Installation

Add SwiftToolkit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/NSFuntik/SwiftToolkit.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "Core", package: "SwiftToolkit")
        ]
    )
]
```
