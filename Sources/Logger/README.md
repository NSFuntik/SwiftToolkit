# Logger

SwiftUI logging system with filtering and search capabilities.

## Features

- Log event visualization
- Filtering by severity
- Tag-based categorization
- Search functionality
- Custom logging formats

## Components

- LogEventView
- LogFilterView
- LogTagView
- SearchBar

## Usage

```swift
import Logger

// Basic logging
Logger.log("Operation started", level: .info)

// Tagged logging
Logger.log("Network request failed", level: .error, tags: ["network"])

// Using in SwiftUI
LoggerView()
    .filter([.error, .warning])
    .tags(["network", "database"])
```
