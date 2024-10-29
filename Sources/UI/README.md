# UI

SwiftUI components and utilities for SwiftToolkit.

## Components

### Buttons
- AsyncButton for async operations
- Custom button styles and modifiers

### ColorPicker
- Customizable color picker
- Style configurations
- Color bar implementation

### PopupView
- Bottom sheet presentations
- Floating popovers
- Expandable views
- QuickLook integration

### ScrollView
- Custom scroll behaviors
- Keyboard dismissal
- Scroll indicators
- Simultaneous scrolling

### SplitView
- Horizontal and vertical splits
- Customizable constraints
- Split styling
- Interactive splitters

### Text Input
- Floating text fields
- Text slider implementation
- Clear button functionality

## Modifiers
- Button extensions
- Pinch to zoom
- Presentation links
- Shadow styling

## Usage

```swift
import UI

struct ContentView: View {
    var body: some View {
        AsyncButton("Load") {
            // Async operation
        }
        
        ColorPickerBar()
            .style(.bordered)
        
        BottomPopupView {
            Text("Popup content")
        }
    }
}
```
