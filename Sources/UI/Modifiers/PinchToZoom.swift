//
//  PinchToZoom.swift
//  SOCAPTEKI
//
//  Created by Dmitry Mikhaylov on 24.11.2023.
//

import SwiftUI

#if canImport(UIKit)

  // MARK: - PinchZoomView

  class PinchZoomView: UIView {
    // Properties

    // MARK: Internal

    weak var delegate: PinchZoomViewDelgate?

    // MARK: Private

    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches = 0

    // Computed Properties

    private(set) var scale: CGFloat = 0 {
      didSet {
        self.delegate?.pinchZoomView(self, didChangeScale: self.scale)
      }
    }

    private(set) var anchor: UnitPoint = .center {
      didSet {
        self.delegate?.pinchZoomView(self, didChangeAnchor: self.anchor)
      }
    }

    private(set) var offset: CGSize = .zero {
      didSet {
        self.delegate?.pinchZoomView(self, didChangeOffset: self.offset)
      }
    }

    private(set) var isPinching = false {
      didSet {
        self.delegate?.pinchZoomView(self, didChangePinching: self.isPinching)
      }
    }

    // Lifecycle

    init() {
      super.init(frame: .zero)

      let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(gesture:)))
      pinchGesture.cancelsTouchesInView = false
      addGestureRecognizer(pinchGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError()
    }

    // Functions

    @objc private func pinch(gesture: UIPinchGestureRecognizer) {
      switch gesture.state {
      case .began:
        self.isPinching = true
        self.startLocation = gesture.location(in: self)
        self.anchor = UnitPoint(x: self.startLocation.x / bounds.width, y: self.startLocation.y / bounds.height)
        self.numberOfTouches = gesture.numberOfTouches

      case .changed:
        if gesture.numberOfTouches != self.numberOfTouches {
          // If the number of fingers being used changes, the start location needs to be adjusted to avoid jumping.
          let newLocation = gesture.location(in: self)
          let jumpDifference = CGSize(width: newLocation.x - self.location.x, height: newLocation.y - self.location.y)
          self.startLocation = CGPoint(x: self.startLocation.x + jumpDifference.width, y: self.startLocation.y + jumpDifference.height)

          self.numberOfTouches = gesture.numberOfTouches
        }

        self.scale = gesture.scale

        self.location = gesture.location(in: self)
        self.offset = CGSize(width: self.location.x - self.startLocation.x, height: self.location.y - self.startLocation.y)

      case .cancelled,
           .ended,
           .failed:
        withAnimation(.interactiveSpring()) {
          self.isPinching = false
          //                scale = 1.0
          //                anchor = .center
          //                offset = .zero
        }

      default:
        break
      }
    }
  }

  // MARK: - PinchZoomViewDelgate

  protocol PinchZoomViewDelgate: AnyObject {
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
  }

  // MARK: - PinchZoom

  struct PinchZoom: UIViewRepresentable {
    // Nested Types

    class Coordinator: NSObject, PinchZoomViewDelgate {
      // Properties

      // MARK: Internal

      var pinchZoom: PinchZoom

      // Lifecycle

      init(_ pinchZoom: PinchZoom) {
        self.pinchZoom = pinchZoom
      }

      // Functions

      func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool) {
        self.pinchZoom.isPinching = isPinching
      }

      func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat) {
        self.pinchZoom.scale = scale
      }

      func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
        self.pinchZoom.anchor = anchor
      }

      func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize) {
        self.pinchZoom.offset = offset
      }
    }

    // Properties

    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    @Binding var offset: CGSize
    @Binding var isPinching: Bool

    // Functions

    func makeCoordinator() -> Coordinator {
      Coordinator(self)
    }

    func makeUIView(context: Context) -> PinchZoomView {
      let pinchZoomView = PinchZoomView()
      pinchZoomView.delegate = context.coordinator
      return pinchZoomView
    }

    func updateUIView(_ pageControl: PinchZoomView, context: Context) {}
  }

  // MARK: - PinchToZoom

  struct PinchToZoom: ViewModifier {
    // Properties

    @State var scale: CGFloat = 1.0
    @State var anchor: UnitPoint = .center
    @State var offset: CGSize = .zero
    @State var isPinching = false

    // Content

    func body(content: Content) -> some View {
      content
        .scaleEffect(self.scale, anchor: self.anchor)
        .offset(self.offset)
        .overlay(PinchZoom(scale: self.$scale, anchor: self.$anchor, offset: self.$offset, isPinching: self.$isPinching))
        .onTapGesture(count: 2, perform: {
          withAnimation(.smooth(duration: 0.6)) {
            if self.scale > 1.5 {
              self.scale = 1.0
            } else {
              self.scale = self.scale * 2
            }
          }
        })
    }
  }

  public extension View {
    func pinchToZoom() -> some View {
      ModifiedContent(content: self, modifier: PinchToZoom())
    }
  }
#endif
