//
//  BottomPopupView.swift
//  SwiftPro
//
//  Created by NSFuntik on 05.09.2024.
//
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Preview Provider

#if DEBUG
struct PopupView_Previews: PreviewProvider {
  static var previews: some View {
    PreviewContent()
  }

  private struct PreviewContent: View {
    @State private var isPresented = false

    var body: some View {
      VStack {
        Spacer()
        Text("Hello, World!")
        Button("Show PopUp") {
          isPresented = true
        }
        Spacer()
      }
      .popup(
        isPresented: $isPresented,
        blurRadius: 3,
        blurAnimation: .interpolatingSpring
      ) {
        ContentUnavailableView(
          "PopUp",
          subheadline: "PopUp Content",
          image: .init(sf: .listBullet),
          actionTitle: "Hide PopUp",
          action: {
            isPresented = false

          }
        )
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        #if os(macOS)
        .background(Color(.selectedContentBackgroundColor))

        #else
        .background(Color(.systemBackground))
        #endif
      }
    }
  }
}
#endif

// MARK: - BottomPopupView

/// A view that presents a bottom popup with customizable content.
///
/// This view uses a `GeometryReader` to manage its layout and renders
/// content received from the initializer. It adjusts its appearance
/// based on safe area insets and applies rounded corners to the top edges.
public struct BottomPopupView<Content: View>: View {
  private let content: Content

  /// Creates a BottomPopupView with the provided content.
  ///
  /// - Parameter content: A closure that returns the view to be displayed
  ///   as the content of the popup.
  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some View {
    GeometryReader { geometry in
      VStack {
        Spacer()
        content
          .padding(.bottom, geometry.safeAreaInsets.bottom)
          #if os(macOS)
        .background(Color(.selectedContentBackgroundColor))

          #else
        .background(Color(.systemBackground))
          #endif
          .clipShape(
            RoundedCornersShape(radius: 16, corners: [.topLeft, .topRight])
          )
      }
      .ignoresSafeArea(.container, edges: .bottom)
    }
    .animation(.easeOut, value: true)
    .transition(.move(edge: .bottom))
  }
}

// MARK: - RoundedCornersShape

/// A shape representing rounded corners.
///
/// This shape allows customizing the radius and the specific corners
/// that should be rounded.
struct RoundedCornersShape: Shape {
  let radius: CGFloat
  let corners: RectCorner

  /// Creates a path for the shape based on the specified rectangle.
  ///
  /// - Parameter rect: The rectangle in which the shape is drawn.
  /// - Returns: A `Path` representing the rounded corners shape.
  func path(in rect: CGRect) -> Path {
    var path = Path()

    let topLeft = corners.contains(.topLeft)
    let topRight = corners.contains(.topRight)
    let bottomLeft = corners.contains(.bottomLeft)
    let bottomRight = corners.contains(.bottomRight)

    let width = rect.width
    let height = rect.height

    // Top left corner
    path.move(to: CGPoint(x: topLeft ? radius : 0, y: 0))

    // Top edge and top right corner
    path.addLine(to: CGPoint(x: width - (topRight ? radius : 0), y: 0))
    if topRight {
      path.addArc(
        center: CGPoint(x: width - radius, y: radius),
        radius: radius,
        startAngle: Angle(degrees: -90),
        endAngle: Angle(degrees: 0),
        clockwise: false
      )
    }

    // Right edge and bottom right corner
    path.addLine(to: CGPoint(x: width, y: height - (bottomRight ? radius : 0)))
    if bottomRight {
      path.addArc(
        center: CGPoint(x: width - radius, y: height - radius),
        radius: radius,
        startAngle: Angle(degrees: 0),
        endAngle: Angle(degrees: 90),
        clockwise: false
      )
    }

    // Bottom edge and bottom left corner
    path.addLine(to: CGPoint(x: bottomLeft ? radius : 0, y: height))
    if bottomLeft {
      path.addArc(
        center: CGPoint(x: radius, y: height - radius),
        radius: radius,
        startAngle: Angle(degrees: 90),
        endAngle: Angle(degrees: 180),
        clockwise: false
      )
    }

    // Left edge and top left corner
    path.addLine(to: CGPoint(x: 0, y: topLeft ? radius : 0))
    if topLeft {
      path.addArc(
        center: CGPoint(x: radius, y: radius),
        radius: radius,
        startAngle: Angle(degrees: 180),
        endAngle: Angle(degrees: 270),
        clockwise: false
      )
    }

    path.closeSubpath()
    return path
  }
}

// MARK: - RectCorner

/// A set of corners for a rectangle.
///
/// This struct conforms to the `OptionSet` protocol, allowing the user to define
/// specific corners of a rectangle for customization. It provides static properties
/// for each corner and a combined set for all corners.
public struct RectCorner: OptionSet {
  public let rawValue: Int
  public static let topLeft = RectCorner(rawValue: 1 << 0)
  public static let topRight = RectCorner(rawValue: 1 << 1)
  public static let bottomLeft = RectCorner(rawValue: 1 << 2)
  public static let bottomRight = RectCorner(rawValue: 1 << 3)
  public static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}

// MARK: - OverlayModifier

/// A modifier that overlays a view with an optional overlay.
///
/// This modifier manages the visibility of the overlay based on the
/// provided binding and allows the application of an overlay view
/// conditionally.
public struct OverlayModifier<OverlayView: View>: ViewModifier {
  @Binding var isPresented: Bool
  let overlayView: OverlayView

  /// Creates an OverlayModifier with the specified binding and overlay view.
  ///
  /// - Parameters:
  ///   - isPresented: A binding that determines if the overlay should be
  ///     presented.
  ///   - overlayView: A closure that returns the overlay view.
  public init(
    isPresented: Binding<Bool>,
    @ViewBuilder overlayView: @escaping () -> OverlayView
  ) {
    self._isPresented = isPresented
    self.overlayView = overlayView()
  }

  public func body(content: Content) -> some View {
    content.overlay(isPresented ? overlayView : nil)
  }
}

// MARK: - View Extension

/// A view extension that adds popup functionality.
///
/// This extension allows any view to present a popup overlay with
/// customizable blur effects and animations when a condition is met.
extension View {
  public func popup<OverlayView: View>(
    isPresented: Binding<Bool>,
    blurRadius: CGFloat = 3,
    blurAnimation: Animation? = .linear,
    @ViewBuilder overlayView: @escaping () -> OverlayView
  ) -> some View {
    blur(radius: isPresented.wrappedValue ? blurRadius : 0)
      .animation(blurAnimation, value: isPresented.wrappedValue)
      .allowsHitTesting(!isPresented.wrappedValue)
      .modifier(
        OverlayModifier(isPresented: isPresented, overlayView: overlayView)
      )
  }
}

// MARK: - Platform Extensions

// #if os(macOS)
//  public extension View {
//    func ignoresSafeArea(_ regions: SafeAreaRegions = .all, edges: Edge.Set = .all) -> some View {
//      self
//    }
//  }
//
//  public enum SafeAreaRegions {
//    case all
//    case container
//  }
// #endif
