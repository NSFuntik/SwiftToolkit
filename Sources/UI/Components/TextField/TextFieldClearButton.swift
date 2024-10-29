//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 16.04.2024.
//

import SwiftUI

public extension View {
  /// Adds a clear button to the view, allowing users to easily clear the text input.
  ///
  /// - Parameter text: A binding to the text input that the clear button will operate on.
  /// - Returns: A view with the clear button added when the text is not empty.
  @ViewBuilder func
    clearButton(
      isActive: Bool = true,
      _ text: Binding<String?>,
      onClear: @escaping () -> Void = {}) -> some View {
    if isActive {
      modifier(TextFieldClearButton(fieldText: text, onClear: onClear))
    }
  }

  @ViewBuilder func
    clearButton(
      isActive: Bool = true,
      _ text: Binding<String>,
      onClear: (() -> Void)? = nil) -> some View {
    if isActive {
      modifier(TextFieldClearButton(fieldText: text, onClear: onClear))
    }
  }
}

// MARK: - TextFieldClearButton

@frozen
public struct TextFieldClearButton: ViewModifier {
  public init(
    fieldText: Binding<String?>,
    onClear: @escaping () -> Void) {
    _fieldText = fieldText.unwrapped("")
    completion = onClear
  }

  public init(
    fieldText: Binding<String>,
    onClear: (() -> Void)?) {
    _fieldText = fieldText
    completion = onClear
  }

  /// A binding to the text input that the clear button will operate on.
  @Binding var fieldText: String

  var completion: (() -> Void)?
  /// Adds the clear button to the view.
  /// - Parameter content: The content view (e.g., a `TextField`) to which the clear button will be added.
  /// - Returns: A view with the clear button added when the text is not empty.
  @ViewBuilder public
  func body(content: Content) -> some View {
    content
      .safeAreaInset(edge: .trailing) {
        Button {
          if !fieldText.isEmpty {
            withAnimation(.bouncy) {
              self.fieldText = ""
              completion?()
            }
          }
        } label: {
          Image(systemName: "xmark.circle")
            .symbolRenderingMode(.hierarchical)
            .imageScale(.large)
            .padding(6)
            .opacity(fieldText.isEmpty ? 0.11 : 1)
        }
      }
  }
}
