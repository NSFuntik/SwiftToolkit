import SwiftUI

@available(iOS, deprecated: 16)
@available(tvOS, deprecated: 16)
@available(macOS, deprecated: 13)
@available(watchOS, deprecated: 9)
extension View {
  /// Disables or enables scrolling in scrollable views.
  ///
  /// Use this modifier to control whether a ``ScrollView`` can scroll:
  ///
  ///     @State private var isScrollDisabled = false
  ///
  ///     var body: some View {
  ///         ScrollView {
  ///             VStack {
  ///                 Toggle("Disable", isOn: $isScrollDisabled)
  ///                 MyContent()
  ///             }
  ///         }
  ///         .backport.scrollDisabled(isScrollDisabled)
  ///     }
  ///
  /// SwiftUI passes the disabled property through the environment, which
  /// means you can use this modifier to disable scrolling for all scroll
  /// views within a view hierarchy. In the following example, the modifier
  /// affects both scroll views:
  ///
  ///      ScrollView {
  ///          ForEach(rows) { row in
  ///              ScrollView(.horizontal) {
  ///                  RowContent(row)
  ///              }
  ///          }
  ///      }
  ///      .backport.scrollDisabled(true)
  ///
  /// You can also use this modifier to disable scrolling for other kinds
  /// of scrollable views, like a ``List`` or a ``TextEditor``.
  ///
  /// - Parameter disabled: A Boolean that indicates whether scrolling is
  ///   disabled.
  @available(iOS, deprecated: 16)
  @available(tvOS, deprecated: 16)
  @available(macOS, deprecated: 13)
  @available(watchOS, deprecated: 9)
  public func scrollDisabled(_ disabled: Bool) -> some View {
    environment(\.isScrollEnabled, !disabled)
    // #if os(iOS)
    //			.any(forType: UIScrollView.self) { proxy in
    //				let scrollView = proxy.instance
    //				scrollView.isScrollEnabled = !disabled
    //				scrollView.alwaysBounceVertical = !disabled
    //				scrollView.alwaysBounceHorizontal = !disabled
    //			}
    // #endif
  }
}
