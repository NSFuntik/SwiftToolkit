import SwiftUI

// MARK: - FramePreferenceKey

private struct FramePreferenceKey: PreferenceKey {
  // Static Properties

  static var defaultValue: CGRect = .zero

  // Static Functions

  static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    value = nextValue()
  }
}

// MARK: - FrameChangeModifier

private struct FrameChangeModifier: ViewModifier {
  // Properties

  let coordinateSpace: CoordinateSpace
  let handler: (CGRect) -> Void

  // Content

  func body(content: Content) -> some View {
    content
      .background(
        GeometryReader {
          Color.clear.preference(
            key: FramePreferenceKey.self,
            value: $0.frame(in: coordinateSpace)
          )
        }
      )
      .onPreferenceChange(FramePreferenceKey.self) {
        guard !$0.isEmpty else {
          return
        }
        handler($0)
      }
  }
}

public extension View {
  func onFrameChange(coordinateSpace: CoordinateSpace = .global, _ handler: @escaping (CGRect) -> Void) -> some View {
    modifier(FrameChangeModifier(coordinateSpace: coordinateSpace, handler: handler))
  }
}

// MARK: - OffsetKey

/// Scroll Content Offset
public struct OffsetKey: PreferenceKey {
  // Static Properties

  public static var defaultValue: CGRect = .zero

  // Static Functions

  public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    value = nextValue()
  }
}

public extension View {
  @ViewBuilder
  func scrollOffset(_ coordinateSpace: CoordinateSpace, completion: @escaping (CGRect) -> Void) -> some View {
    overlay {
      GeometryReader {
        let rect = $0.frame(in: coordinateSpace)

        Color.clear
          .preference(key: OffsetKey.self, value: rect)
          .onPreferenceChange(OffsetKey.self) { newRect in
            Task {
              await MainActor.run {
                completion(newRect)
              }
            }
          }
      }
    }
    .animation(.linear, value: coordinateSpace)
  }
}

// MARK: - AnimationEndedCallback

private struct AnimationEndedCallback<Value: VectorArithmetic>: Animatable, ViewModifier {
  // Properties

  // MARK: Internal

  var endValue: Value
  var onEnd: () -> Void

  // Computed Properties

  var animatableData: Value {
    didSet {
      checkIfFinished()
    }
  }

  // Lifecycle

  init(for value: Value, onEnd: @escaping () -> Void) {
    animatableData = value
    endValue = value
    self.onEnd = onEnd
  }

  // Content

  func body(content: Content) -> some View {
    content
  }

  // Functions

  // MARK: Private

  private func checkIfFinished() {
    if endValue == animatableData {
      DispatchQueue.main.async {
        onEnd()
      }
    }
  }
}

public extension View {
  @ViewBuilder
  func checkAnimationEnded(for value: some VectorArithmetic, onEnd: @escaping () -> Void) -> some View {
    modifier(AnimationEndedCallback(for: value, onEnd: onEnd))
  }
}
