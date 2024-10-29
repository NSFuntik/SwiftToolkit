# Feedback

Haptic, audio, and visual feedback system.

## Features

### Audio Feedback
- System sound playback
- Custom audio feedback
- Audio player management

### Haptic Feedback
- System haptics
- Pattern haptics
- Custom haptic patterns

### Visual Feedback
- Flash animations
- Visual indicators
- Status notifications

## Usage

```swift
import Feedback

// Haptic feedback
Haptic.impact(.medium).trigger()

// Audio feedback
AudioFeedback.playSystemSound(.tap)

// Visual feedback
Flash.success("Operation completed")
```
