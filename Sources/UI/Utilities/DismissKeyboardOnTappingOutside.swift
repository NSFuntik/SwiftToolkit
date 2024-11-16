//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 16.05.2024.
//

import SwiftUI

extension View {
  public dynamic func dismissKeyboardGestures() -> some View {
    ModifiedContent(content: self, modifier: DismissKeyboardOnTappingOutside())
  }
}

// MARK: - DismissKeyboardOnTappingOutside

@frozen public struct DismissKeyboardOnTappingOutside: ViewModifier {
  // Computed Properties

  private var swipeGesture: some Gesture {
    DragGesture(minimumDistance: 10, coordinateSpace: .global)
      .onChanged(self.endEditing)
  }

  // Content

  public func body(content: Content) -> some View {
    content
      .allowsHitTesting(true)
      .onTapGesture {
        #if os(iOS)
        UIApplication.shared.endEditing()
        #endif
      }
      .gesture(self.swipeGesture)
  }

  // Functions

  private func endEditing(_: DragGesture.Value) {
    #if os(iOS)
    UIApplication.shared.endEditing()
    #endif
  }
}

#if DEBUG
struct DismissKeyboardOnTappingOutside_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Spacer()
      FloatingTextField(placeholderText: "Preveiw", placeholderOffset: .nan, scaleEffectValue: .zero) { _, _ in
      }
      Spacer()
    }.dismissKeyboardGestures()
  }
}
#endif
