import SwiftUI

#if canImport(UIKit)
  /// A view modifier for displaying a floating popover over a given anchor view.
  ///
  /// This view modifier provides the ability to present a popover view as a floating overlay
  /// over an anchor view when the `isPresented` binding is `true`.
  ///
  /// - Parameters:
  ///   - isPresented: A binding that controls whether the popover should be presented.
  ///   - contentBlock: A closure returning the content of the popover, which conforms to the `View` protocol.
  ///
  /// This view modifier is designed to work as a part of a view hierarchy and should be applied to a view to enable popover presentation.
  ///
  /// For iOS 15 compatibility, it includes a workaround for the missing `@StateObject` property wrapper, which uses an internal `Root` to manage the anchor view.
  extension Bool: Identifiable { public var id: Bool { self } }
  struct FloatingPopover<Item, PopoverContent>: ViewModifier where Item: Identifiable, PopoverContent: View {
    init(
      item: Binding<Item?>,
      @ViewBuilder contentBlock: @escaping (Item) -> PopoverContent) {
      self._item = item
      self.contentBlock = contentBlock
      self.contentOptional = nil
    }

    init(
      isPresented: Binding<Bool>,
      @ViewBuilder contentBlock: @escaping () -> PopoverContent) where Item == Bool {
      self._item = .init(get: {
        let bool: Bool? = isPresented.wrappedValue
        return bool
      }, set: {
        guard let _ = $0 else { isPresented.wrappedValue = false; return }
        isPresented.wrappedValue = true
      })
      self.contentOptional = contentBlock
    }

    /// A binding that controls whether the popover should be presented.
    @Binding var item: Item?

    /// A closure returning the content of the popover.
    @State var contentBlock: ((Item) -> PopoverContent)?

    @State var contentOptional: (() -> PopoverContent)?

    /// Workaround for missing @StateObject in iOS 15.
    private struct Parent {
      var anchorView = UIView()
    }

    @State private var perent = Parent()

    /// Modifies the content view by adding popover presentation logic.
    ///
    /// If `isPresented` is `true`, this modifier presents the popover containing the provided content.
    ///
    /// - Parameter content: The content view to be modified.
    /// - Returns: A view with popover presentation capabilities.
    @usableFromInline
    func body(content: Content) -> some View {
      if let item = item {
        withAnimation(.bouncy) {
          presentPopover(with: item)
        }
      }

      return Button(action: {
        withAnimation(.bouncy) {
          if let item = item {
            withAnimation(.bouncy) {
              presentPopover(with: item)
            }
          }
        }
      }, label: {
        content
          .background(InternalAnchorView(uiView: perent.anchorView).background(Color.black))
      })
    }

    private func presentPopover(with item: Item) {
      var contentController: ContentViewController<PopoverContent>
      if let contentBlock = contentBlock {
        contentController = ContentViewController(
          rootView: contentBlock(item),
          isPresented: .init(get: {
            $item.wrappedValue != nil
          }, set: { newState in
            self.item = newState ? $item.wrappedValue : nil
          }))
      } else {
        guard let contentOptional = contentOptional else { return }
        contentController = ContentViewController(
          rootView: contentOptional(),
          isPresented: .init(get: {
            $item.wrappedValue != nil
          }, set: { newState in
            self.item = newState ? $item.wrappedValue : nil
          }))
      }
      contentController.modalPresentationStyle = .popover

      let view = perent.anchorView
      view.backgroundColor = .black
      guard let popover = contentController.popoverPresentationController else { return }
      popover.sourceView = view
      popover.sourceRect = view.bounds
      popover.delegate = contentController
      popover.backgroundColor = UIColor.black
      guard let sourceVC = view.closestVC() else { return }
      if let presentedVC = sourceVC.presentedViewController {
        presentedVC.dismiss(animated: true) {
          sourceVC.present(contentController, animated: true)
        }
      } else {
        sourceVC.present(contentController, animated: true)
      }
    }

    /// A private struct that represents an internal anchor view.
    private struct InternalAnchorView: UIViewRepresentable {
      typealias UIViewType = UIView
      @State var uiView: UIView

      func makeUIView(context: Self.Context) -> Self.UIViewType {
        uiView.backgroundColor = UIColor.white
        return uiView
      }

      func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) {
        self.uiView = uiView
      }
    }

    private class ContentViewController<V>: UIHostingController<V>, UIPopoverPresentationControllerDelegate where V: View {
      @Binding var isPresented: Bool
      var size: CGSize = .init(width: 300, height: 400)
      init(rootView: V, isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        super.init(rootView: rootView)
      }

      @available(*, unavailable)
      @MainActor @objc dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
      }

      override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        size = sizeThatFits(in: UIView.layoutFittingExpandedSize)
        preferredContentSize = size
      }

      func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .popover
      }

      func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        $isPresented.animation(.bouncy).wrappedValue = false
      }
    }
  }

  public extension View {
    /// A view modifier that presents a floating popover view for an identifiable item.
    ///
    /// This method applies a floating popover presentation for the specified item.
    /// If iOS 16.4 or later is available, it uses the built-in popover presentation.
    /// For earlier versions, it utilizes the `FloatingPopover` modifier.
    ///
    /// - Parameters:
    ///   - item: A binding to an optional identifiable item that, when not `nil`,
    ///            will trigger the presentation of the popover.
    ///   - content: A closure that returns the content to be displayed inside the popover for the specified item.
    @ViewBuilder
    func floatingPopover<Item: Identifiable>(
      item: Binding<Item?>,
      @ViewBuilder content: @escaping (Item) -> some View) -> some View {
      if #available(iOS 16.4, *) {
        popover(item: item) { item in
          content(item)
            .presentationCompactAdaptation(.popover)
            .fixedSize()
        }
      } else {
        modifier(FloatingPopover(item: item, contentBlock: content))
      }
    }

    /// A view modifier that presents a floating popover view based on a binding boolean state.
    ///
    /// This method applies a floating popover presentation that is controlled by
    /// a boolean binding. If iOS 16.4 or later is available, it uses the built-in
    /// popover presentation. For earlier versions, it utilizes the `FloatingPopover` modifier.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls the visibility of the popover.
    ///   - content: A closure that returns the content to be displayed within the popover.
    @ViewBuilder
    func floatingPopover(
      isPresented: Binding<Bool>,
      @ViewBuilder content: @escaping () -> some View) -> some View {
      if #available(iOS 16.4, *) {
        popover(isPresented: isPresented) {
          content()
            .presentationCompactAdaptation(.popover)
            .fixedSize()
        }
      } else {
        modifier(FloatingPopover(isPresented: isPresented, contentBlock: content))
      }
    }
  }
#endif
