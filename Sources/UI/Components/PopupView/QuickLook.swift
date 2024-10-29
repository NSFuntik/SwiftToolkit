import SwiftUI

#if canImport(QuickLook)
  import QuickLook
#endif

@available(iOS, deprecated: 14)
@available(macOS, deprecated: 11)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension View {
  /// Presents a Quick Look preview of the URLs you provide.
  ///
  /// The Quick Look preview appears when you set the binding to a non-`nil` item.
  /// When you set the item back to `nil`, Quick Look dismisses the preview.
  /// If the value of the selection binding isn’t contained in the items collection, Quick Look treats it the same as a `nil` selection.
  ///
  /// Quick Look updates the value of the selection binding to match the URL of the file the user is previewing.
  /// Upon dismissal by the user, Quick Look automatically sets the item binding to `nil`.
  ///
  /// - Parameters:
  ///     - selection: A <doc://com.apple.documentation/documentation/SwiftUI/Binding> to an element that’s part of the items collection. This is the URL that you currently want to preview.
  ///     - items: A collection of URLs to preview.
  ///
  /// - Returns: A view that presents the preview of the contents of the URL.
  func quickLookPreview<Items>(_ selection: Binding<Items.Element?>, in items: Items) -> some View where Items: RandomAccessCollection, Items.Element == URL {
    #if os(iOS) || os(macOS)
      background(QuicklookSheet(selection: selection, items: items))
    #else
      self
    #endif
  }

  /// Presents a Quick Look preview of the contents of a single URL.
  ///
  /// The Quick Look preview appears when you set the binding to a non-`nil` item.
  /// When you set the item back to `nil`, Quick Look dismisses the preview.
  ///
  /// Upon dismissal by the user, Quick Look automatically sets the item binding to `nil`.
  /// Quick Look displays the preview when a non-`nil` item is set.
  /// Set `item` to `nil` to dismiss the preview.
  ///
  /// - Parameters:
  ///     - item: A <doc://com.apple.documentation/documentation/SwiftUI/Binding> to a URL that should be previewed.
  ///
  /// - Returns: A view that presents the preview of the contents of the URL.
  func quickLook(_ item: Binding<URL?>) -> some View {
    #if os(iOS) || os(macOS)
      background(QuicklookSheet(selection: item, items: [item.wrappedValue].compactMap { $0 }))
    #else
      self
    #endif
  }
}

#if os(macOS)
  import QuickLookUI

  private struct QuicklookSheet<Items>: NSViewControllerRepresentable where Items: RandomAccessCollection, Items.Element == URL {
    let selection: Binding<Items.Element?>
    let items: Items

    func makeNSViewController(context _: Context) -> PreviewController<Items> {
      .init(selection: selection, in: items)
    }

    func updateNSViewController(_ controller: PreviewController<Items>, context _: Context) {
      controller.selection = selection
      controller.items = items
    }
  }

#elseif os(iOS)

  private struct QuicklookSheet<Items>: UIViewControllerRepresentable where Items: RandomAccessCollection, Items.Element == URL {
    let selection: Binding<Items.Element?>
    let items: Items

    func makeUIViewController(context _: Context) -> PreviewController<Items> {
      .init(selection: selection, in: items)
    }

    func updateUIViewController(_ controller: PreviewController<Items>, context _: Context) {
      controller.items = items
      controller.selection = selection
    }
  }

#endif

#if os(macOS)
  import QuickLook
  import QuickLookUI

  final class PreviewController<Items>: NSViewController, QLPreviewPanelDataSource, QLPreviewPanelDelegate where Items: RandomAccessCollection, Items.Element == URL {
    private let panel = QLPreviewPanel.shared()!
    private weak var windowResponder: NSResponder?

    var items: Items

    var selection: Binding<Items.Element?> {
      didSet {
        updateControllerLifecycle(
          from: oldValue.wrappedValue,
          to: selection.wrappedValue)
      }
    }

    private func updateControllerLifecycle(from oldValue: Items.Element?, to newValue: Items.Element?) {
      switch (oldValue, newValue) {
      case (.none, .some):
        present()
      case (.some, .some):
        update()
      case (.some, .none):
        dismiss()
      case (.none, .none):
        break
      }
    }

    init(selection: Binding<Items.Element?>, in items: Items) {
      self.selection = selection
      self.items = items
      super.init(nibName: nil, bundle: nil)
      self.windowResponder = NSApp.mainWindow?.nextResponder
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
      view = .init(frame: .zero)
    }

    var isVisible: Bool {
      QLPreviewPanel.sharedPreviewPanelExists() && panel.isVisible
    }

    private func present() {
      NSApp.mainWindow?.nextResponder = self

      if isVisible {
        panel.updateController()
        let index = selection.wrappedValue.flatMap { items.firstIndex(of: $0) }
        panel.currentPreviewItemIndex = items.distance(from: items.startIndex, to: index ?? items.startIndex)
      } else {
        panel.makeKeyAndOrderFront(nil)
      }
    }

    private func update() {
      present()
    }

    private func dismiss() {
      selection.wrappedValue = nil
    }

    func numberOfPreviewItems(in _: QLPreviewPanel!) -> Int {
      items.isEmpty ? 1 : items.count
    }

    func previewPanel(_: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
      if items.isEmpty {
        return selection.wrappedValue as? NSURL
      } else {
        let index = items.index(items.startIndex, offsetBy: index)
        return items[index] as NSURL
      }
    }

    override func acceptsPreviewPanelControl(_: QLPreviewPanel!) -> Bool {
      true
    }

    override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
      panel.dataSource = self
      panel.reloadData()
    }

    override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
      panel.dataSource = nil
      dismiss()
    }
  }

#endif

#if os(iOS)
  import QuickLook

  final class PreviewController<Items>: UIViewController, UIAdaptivePresentationControllerDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource where Items: RandomAccessCollection, Items.Element == URL {
    var items: Items

    var selection: Binding<Items.Element?> {
      didSet {
        updateControllerLifecycle(
          from: oldValue.wrappedValue,
          to: selection.wrappedValue)
      }
    }

    init(selection: Binding<Items.Element?>, in items: Items) {
      self.selection = selection
      self.items = items
      super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    private func updateControllerLifecycle(from oldValue: Items.Element?, to newValue: Items.Element?) {
      switch (oldValue, newValue) {
      case (.none, .some):
        presentController()
      case (.some, .some):
        updateController()
      case (.some, .none):
        dismissController()
      case (.none, .none):
        break
      }
    }

    private func presentController() {
      let controller = QLPreviewController(nibName: nil, bundle: nil)
      controller.dataSource = self
      controller.delegate = self
      present(controller, animated: true)
      updateController()
    }

    private func updateController() {
      let controller = presentedViewController as? QLPreviewController
      controller?.reloadData()
      let index = selection.wrappedValue.flatMap { items.firstIndex(of: $0) }
      controller?.currentPreviewItemIndex = items.distance(from: items.startIndex, to: index ?? items.startIndex)
    }

    private func dismissController() {
      DispatchQueue.main.async {
        self.selection.wrappedValue = nil
      }
    }

    func numberOfPreviewItems(in _: QLPreviewController) -> Int {
      items.isEmpty ? 1 : items.count
    }

    func previewController(_: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
      if items.isEmpty {
        return (selection.wrappedValue ?? URL(fileURLWithPath: "")) as NSURL
      } else {
        let index = items.index(items.startIndex, offsetBy: index)
        return items[index] as NSURL
      }
    }

    func previewControllerDidDismiss(_: QLPreviewController) {
      dismissController()
    }
  }
#endif
