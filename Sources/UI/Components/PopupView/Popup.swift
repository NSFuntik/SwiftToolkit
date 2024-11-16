//
//  Popup.swift
//
//
//  Created by Dmitry Mikhaylov on 09.04.2024.
//
import SwiftUI

// @available(iOS 17.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
// #Preview {
//
//  PopupPreview()
//
// }
// @available(iOS 17.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
// private struct PopupPreview: View {
//  @State var isPresented = false
//
//  var body: some View {
//
//    VStack {
//      Spacer()
//      HStack {
//        Spacer()
//        Text("Hellxo, World!")
//      }
//      Button("Show PopUp") {
//        isPresented = true
//      }.buttonStyle(.borderedProminent)
//      Spacer()
//      Spacer()
//    }
//    .background(.purple)
//    .background(ignoresSafeAreaEdges: .all)
//    .popup(isPresented: $isPresented) {
//      ContentUnavailableView(
//        "PopUp",
//        symbol: "list.bullet",
//        actionTitle: "Hide PopUp",
//        actionSymbol: .rectangleFillBadgeXmark,
//        action: { isPresented = false },
//        content: { Text("PopUp Content") }
//      ).frame(width: .screenWidth, height: 300).background(.bar)
//    }
//  }
// }

extension View {
  /// Presents a popup view using a specified item and alignment.
  ///
  /// - Parameters:
  ///   - alignment: The alignment for the popup view.
  ///   - item: A binding to an optional item that triggers the popup when non-nil.
  ///   - content: A closure that returns the content of the popup based on the provided item.
  /// - Returns: A view modified to show a popup if the item is non-nil.
  public func popup<PopupContent: View, Item: Hashable>(
    alignment: Alignment,
    item: Binding<Item?>,
    @ViewBuilder content: @escaping (Item) -> PopupContent
  ) -> some View {
    self
      .allowsHitTesting((item.wrappedValue == nil))
      .modifier(Popup(alignment: alignment, item: item, content: content))
  }

  /// Presents a popup view using a binding to a `Popup` instance.
  ///
  /// - Parameters:
  ///   - popup: A binding to an optional `Popup` instance.
  /// - Returns: A view modified to show a popup if the `Popup` instance is non-nil.
  @ViewBuilder
  public func popup<PopupContent: View, Item: Hashable>(
    popup: Binding<Popup<PopupContent, Item>?>
  ) -> some View {
    if let popup = popup.wrappedValue {
      self
        .allowsHitTesting((popup.item == nil))
        .popup(
          alignment: popup.alignment,
          item: popup.$item,
          content: popup.popup!
        )
    } else {
      self
    }
  }

  /// Presents a popup view using a Boolean to control its visibility and a specified alignment.
  ///
  /// - Parameters:
  ///   - alignment: The alignment for the popup view.
  ///   - isPresented: A binding to a Boolean that controls the visibility of the popup.
  ///   - content: A closure that returns the content of the popup based on the visibility state.
  /// - Returns: A view modified to show a popup based on the visibility state.
  public func popup<PopupContent: View>(
    alignment: Alignment = .bottom,
    isPresented: Binding<Bool>,
    @ViewBuilder content: @escaping () -> PopupContent
  ) -> some View {
    self
      .allowsHitTesting(!isPresented.wrappedValue)
      .modifier(
        Popup(alignment: alignment, isPresented: isPresented, content: content)
      )
  }
}

// MARK: - Popup

/// A view modifier that presents a popup view based on a specified item.
///
/// The `Popup` struct conforms to `ViewModifier` and `Hashable`, allowing it to be used as a view modifier in SwiftUI.
/// It shows a popup view based on the given item and allows for dismissal via a drag gesture.
///
/// - Parameters:
///   - alignment: The alignment for the popup view.
///   - item: A binding to an optional item that triggers the popup when non-nil.
///   - content: A closure that returns the content of the popup based on the provided item.
public struct Popup<PopupContent: View, Item: Hashable>: ViewModifier, Hashable {
  /// Compares two `Popup` instances for equality.
  public static func == (
    lhs: Popup<PopupContent, Item>,
    rhs: Popup<PopupContent, Item>
  ) -> Bool {
    return lhs.alignment == rhs.alignment && lhs.item == rhs.item
      && lhs.hashValue == rhs.hashValue
  }

  /// Hashes the essential components of this value by feeding them into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(item)
    hasher.combine(offset)
  }

  var shouldDismiss: Bool = true

  @ViewBuilder
  public var popupContent: some View {
    if let popup = self.popup, let item = self.item {
      popup(item)
    } else {
      popupEntry?()
    }
  }

  /// Describes the view content and behavior of the popup modifier.
  ///
  /// - Parameter content: The content view to which the popup will be added.
  /// - Returns: A view that represents the popup content overlaid on the original view.
  @ViewBuilder
  public func body(content: Content) -> some View {
    content
      .overlay(alignment: alignment) {
        if self.item != nil || isPresented {
          BackdropBlurView(
            onTap: hidePopup
          )
          .onTapGesture(perform: hidePopup)
          .ignoresSafeArea(.container)
          .overlay(alignment: alignment) {
            popupContent

              .viewSize($size)
              .offset(y: offset)
              .gesture(
                DragGesture()
                  .onChanged { value in
                    if alignment == .bottom {
                      if value.translation.height < size.height {
                        withAnimation {
                          offset = value.translation.height
                        }
                      }
                    } else if alignment == .top {
                      if value.translation.height > -size.height {
                        withAnimation {
                          offset = value.translation.height
                        }
                      }
                    }
                  }
                  .onEnded { _ in
                    withAnimation {
                      if alignment == .bottom {
                        if offset <= size.height / 2 {
                          offset = 0
                        } else {
                          hidePopup()
                          offset = 0
                        }
                      } else if alignment == .top {
                        if offset >= -size.height / 2 {
                          offset = 0
                        } else {
                          hidePopup()
                          offset = 0
                        }
                      }
                    }
                  }
              )
              .onAppear(perform: {
                if shouldDismiss {
                  DispatchQueue.main.asyncAfter(
                    deadline: .now() + 1.5,
                    execute: hidePopup
                  )
                }
              })
              .background(
                Color.black.opacity(0.3).onTapGesture {}
              )
          }
          .padding(16, 12)
          .clipped()
          .background(.clear)
          .transition(
            .move(edge: alignment == .bottom ? .bottom : .top).combined(
              with: .offset(y: alignment == .bottom ? -100 : 100)
            ).animation(.bouncy)
          )
        }
      }
      .animation(.snappy, value: isPresented)
      .animation(.interactiveSpring, value: offset)
      .animation(.bouncy(duration: 0.3), value: size)
  }

  func hidePopup() {
    withAnimation(.bouncy) {
      isPresented = false
      self.item = .none
    }
  }

  @Binding var isPresented: Bool
  var popupEntry: (() -> PopupContent)?
  var popup: ((Item) -> PopupContent)?
  @Binding var item: Item?
  @State private var offset: CGFloat = .zero
  @State private var size: CGSize = .zero
  let alignment: Alignment
  /// Creates a new `Popup` modifier with the specified alignment, item binding, and content closure.
  ///
  /// - Parameters:
  ///   - alignment: The alignment for the popup view.
  ///   - item: A binding to an optional item that triggers the popup when non-nil.
  ///   - content: A closure that returns the content of the popup based on the provided item.
  public init(
    alignment: Alignment = .top,
    item: Binding<Item?>,
    @ViewBuilder content: @escaping (Item) -> PopupContent
  ) {
    self.alignment = alignment
    self._item = item
    self.popup = content
    self.popupEntry = nil
    self.shouldDismiss = true
    self._isPresented = .constant(false)
  }

  /// Creates a new `Popup` modifier with the specified alignment, presentation state, and content closure.
  ///
  /// - Parameters:
  ///   - alignment: The alignment for the popup view.
  ///   - isPresented: A binding to a Boolean that controls the visibility of the popup.
  ///   - content: A closure that returns the content of the popup based on the visibility state.
  public init(
    alignment: Alignment = .top,
    isPresented: Binding<Bool>,
    @ViewBuilder content: @escaping () -> PopupContent
  ) where Item == Bool {
    self.alignment = alignment
    self.shouldDismiss = false
    self._isPresented = isPresented
    self._item = .constant(nil)
    self.popupEntry = content
    self.popup = nil
  }
}
