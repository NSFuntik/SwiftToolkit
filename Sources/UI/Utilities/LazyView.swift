//
//  LazyView.swift
//
//
//  Created by Dmitry Mikhaylov on 16.05.2024.
//

import SwiftUI

public struct LazyView<Content: View>: View {
  private let build: () -> Content

  public init(_ build: @autoclosure @escaping () -> Content) {
    self.build = build
  }

  public var body: Content {
    build()
  }
}
