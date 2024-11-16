//
//  Shimmer.swift
//  SwiftUI-Shimmer
//  Created by Vikram Kriplaney on 23.03.21.
//

import Core
import SwiftUI

// MARK: - Shimmer

/// A view modifier that applies an animated "shimmer" to any view, typically to show that an operation is in progress.
public struct Shimmer: ViewModifier {
  @State private var isInitialState = true
  var isActive: Bool
  public init(isActive: Bool = true) {
    self.isActive = isActive
  }

  public func body(content: Content) -> some View {
    content
      .if(isActive) {
        $0
          .mask(
            LinearGradient(
              gradient: .init(colors: [.black.opacity(0.4), .black, .black.opacity(0.4)]),
              startPoint: isInitialState ? .init(x: -0.3, y: -0.3) : .init(x: 1, y: 1),
              endPoint: isInitialState ? .init(x: 0, y: 0) : .init(x: 1.3, y: 1.3)
            )
          )

          //                    .scaleEffect(isInitialState ? 1.5 : 1)
          .animation(.linear(duration: 1.33).delay(0.33).repeatForever(autoreverses: false), value: isInitialState)
          .onAppear {
            isInitialState = false
          }
      }
  }
}

extension View {
  /// Applies the `Shimmer` view modifier to the current view.
  public func shimmering(active: Bool = true) -> some View {
    modifier(Shimmer(isActive: active))
  }
}

#if DEBUG
struct Shimmer_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      Text("SwiftUI Shimmer")
      if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
        Text("SwiftUI Shimmer").preferredColorScheme(.light)
        Text("SwiftUI Shimmer").preferredColorScheme(.dark)
        VStack(alignment: .leading) {
          Text("Loading...").font(.title)
          Text(String(repeating: "Shimmer", count: 12))
            .redacted(reason: .placeholder)
        }.frame(maxWidth: 200)
      }
    }
    .padding()
    .shimmering()
    .previewLayout(.sizeThatFits)

    VStack(alignment: .leading) {
      Text("مرحبًا")
      Text("← Right-to-left layout direction").font(.body)
      Text("שלום")
    }
    .font(.largeTitle)
    .shimmering()
    .environment(\.layoutDirection, .rightToLeft)
  }
}
#endif
