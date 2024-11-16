//
//  FloatingTextField.swift
//
//
//  Created by Dmitry Mikhaylov on 26.04.2024.
//

import SwiftUI

// MARK: - FloatingTextField

/// A view that represents a floating text field with placeholder functionality.
///
/// This component animates the placeholder text, moving it upwards when the text field is active.
public struct FloatingTextField: View {
  let placeholderText: String
  @State private var text: String = ""

  let animation: Animation = .spring(response: 0.1, dampingFraction: 0.6)

  @State private var placeholderOffset: CGFloat
  @State private var scaleEffectValue: CGFloat

  private var onTextAction: ((_ oldValue: String, _ newValue: String) -> Void)?

  /// Creates a new instance of `FloatingTextField`.
  ///
  /// - Parameters:
  ///   - placeholderText: The text that will be displayed as a placeholder.
  ///   - placeholderOffset: The vertical offset for the placeholder when the text field is not empty.
  ///   - scaleEffectValue: The scale effect value for the placeholder.
  ///   - colorPalette: A tuple containing the primary and secondary colors for the text field.
  ///   - onTextAction: A closure that is called when the text changes.
  public init(
    placeholderText: String,
    placeholderOffset offset: CGFloat = 0,
    scaleEffectValue scale: CGFloat = 1,
    colorPalette: (primary: Color, secondary: Color) = (.accentColor, .secondary),
    onTextAction: ((_: String, _: String) -> Void)? = nil
  ) {
    self.placeholderText = placeholderText
    self._placeholderOffset = State(initialValue: offset)
    self._scaleEffectValue = State(initialValue: scale)
    self.colorPalette = colorPalette
    self.onTextAction = onTextAction
  }

  var colorPalette: (primary: Color, secondary: Color)

  /// The view body that contains the text field and its placeholder.
  public var body: some View {
    ZStack(alignment: .leading) {
      Text(placeholderText)
        .foregroundStyle($text.wrappedValue.isEmpty ? colorPalette.primary : colorPalette.secondary)
        .font($text.wrappedValue.isEmpty ? .headline : .caption)
        .offset(y: placeholderOffset)
        .scaleEffect(scaleEffectValue, anchor: .leading)
      TextField("", text: $text)
        .font(.headline)
        .foregroundStyle(colorPalette.primary)
    }
    .padding(12, 16)
    .overlay(
      Capsule(style: .continuous)
        .stroke(colorPalette.primary.opacity(0.66), lineWidth: 1.3)
    )
    .onChange(of: text) { newValue in
      withAnimation(animation) {
        placeholderOffset = $text.wrappedValue.isEmpty ? 0 : -25
        scaleEffectValue = $text.wrappedValue.isEmpty ? 1 : 0.75
      }
      onTextAction?(text, newValue)
    }
  }
}

/// Extension methods for `FloatingTextField`.
extension FloatingTextField {
  /// Adds a closure to be called when the text changes.
  ///
  /// - Parameter onTextAction: A closure that is called when the text changes, providing the old and new values.
  /// - Returns: The modified `FloatingTextField` instance.
  public func onTextChange(_ onTextAction: ((_ oldValue: String, _ newValue: String) -> Void)?) -> Self {
    var view = self
    view.onTextAction = onTextAction
    return view
  }
}

#Preview {
  FloatingTextField(placeholderText: "kjbjpl'").foregroundStyle(.purple, .red)
}
