# STCoding

Advanced encoding and decoding utilities.

## Features

### AnyCodable
- Type-erased encoding/decoding
- Flexible data conversion
- Protocol conformance

### JSON
- JSON parsing and serialization
- Type-safe conversions
- Error handling

### Storage
- Persistent storage abstractions
- URL-encoded string handling
- Set extensions

## Usage

```swift
import STCoding

// Using AnyCodable
let value = AnyCodable(["key": "value"])

// JSON handling
let json = try JSON(data: jsonData)
let value = json["key"].string

// Storage
@StorageCodable("user_settings")
var settings: Settings
```
