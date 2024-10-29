# STFoundation

Foundation extensions and utilities for SwiftToolkit.

## Features

### Compressor
- Data compression utilities
- Error handling for compression operations

### Data Units
- Data unit conversions and formatting
- Image data handling extensions

### Time Interval
- Time interval formatting and calculations
- Date and time utilities

### URL Extensions
- URL manipulation and formatting
- URL validation and processing

## Installation

Add this to your package dependencies:
```swift
.package(url: "https://github.com/yourusername/SwiftToolkit.git", from: "1.0.0"),
```

Then include "STFoundation" as a dependency for your target:
```swift
.target(name: "YourTarget", dependencies: ["STFoundation"])
```

## Usage

```swift
import STFoundation

// Compression example
let compressor = Compressor()

// Time formatting
let interval = TimeInterval(360)
let formatted = interval.formatted() // "6 minutes"

// URL manipulation
let url = URL(string: "https://example.com")!
let modified = url.appendingQueryItems(["key": "value"])
```
