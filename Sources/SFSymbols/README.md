# SFSymbols

Type-safe SF Symbols integration.

## Features

- Enum-based symbol access
- Social media icons
- Symbol search functionality
- Generated symbol constants

## Usage

```swift
import SFSymbols

// Using symbol enum
Image(systemName: SFSymbol.star.rawValue)

// Social icons
SocialIcons.facebook

// Symbol search
let symbols = SymbolFinder.search("star")
```
