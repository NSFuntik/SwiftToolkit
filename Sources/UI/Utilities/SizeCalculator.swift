//
//  SizeCalculator.swift
//  Mood
//
//  Created by Dmitry Mikhailov on 08.10.2024.
//

import SwiftUI

// MARK: - ViewSizeKey

struct ViewSizeKey: PreferenceKey {
  static var defaultValue: CGSize?
  static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) { value = nextValue() }
}

extension View {
  /// A view modifier that allows views to report their size to a binding.
  /// - Parameter size: A binding to a CGSize that will be updated with the size of the view.
  /// - Returns: A modified view that will report its size.
  public func viewSize(_ size: Binding<CGSize>) -> some View {
    modifier(SizeCalculator(size: size))
  }
}

// MARK: - SizeCalculator

/// A view modifier that captures the size of the view it is applied to and updates a bound CGSize.
public struct SizeCalculator: ViewModifier {
  @Binding var size: CGSize
  /// The body of the view modifier.
  /// - Parameter content: The content of the view that this modifier is applied to.
  /// - Returns: A view that tracks its size and updates the bound size value.
  public func body(content: Content) -> some View {
    content.background {
      GeometryReader { geometry in
        Color.clear.preference(key: ViewSizeKey.self, value: geometry.size)
      }.onPreferenceChange(ViewSizeKey.self) { result in DispatchQueue.main.async { size = result ?? .zero } }
    }
  }
}
