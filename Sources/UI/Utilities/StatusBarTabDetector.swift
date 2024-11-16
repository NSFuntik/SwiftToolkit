//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 16.04.2024.
//

import SwiftUI

#if os(iOS)
extension View {
  /// for this to work make sure all the other scrollViews have scrollsToTop = false
  public func onStatusBarTap(onTap: @escaping () -> Void) -> some View {
    overlay {
      StatusBarTabDetector(onTap: onTap)
        .offset(y: .screenHeight)
    }
  }
}

private struct StatusBarTabDetector: UIViewRepresentable {
  var onTap: () -> Void

  func makeUIView(context: Context) -> UIView {
    let fakeScrollView = UIScrollView()
    fakeScrollView.contentOffset = CGPoint(x: 0, y: 10)
    fakeScrollView.delegate = context.coordinator
    fakeScrollView.scrollsToTop = true
    fakeScrollView.contentSize = CGSize(width: 100, height: UIScreen.main.bounds.height * 2)
    return fakeScrollView
  }

  func updateUIView(_ uiView: UIView, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(onTap: onTap)
  }

  class Coordinator: NSObject, UIScrollViewDelegate {
    var onTap: () -> Void

    init(onTap: @escaping () -> Void) {
      self.onTap = onTap
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
      onTap()
      return false
    }
  }
}
#endif
