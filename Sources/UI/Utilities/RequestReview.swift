import StoreKit
import SwiftUI

#if os(iOS) || os(macOS)
@available(iOS, deprecated: 16)
@available(macOS, deprecated: 13)
extension EnvironmentValues {
  /// An instance that tells StoreKit to request an App Store rating or review from the user, if appropriate.
  /// Read the requestReview environment value to get an instance of this structure for a given Environment. Call the instance to tell StoreKit to ask the user to rate or review your app, if appropriate. You call the instance directly because it defines a callAsFunction() method that Swift calls when you call the instance.
  ///
  /// Although you normally call this instance to request a review when it makes sense in the user experience flow of your app, the App Store policy governs the actual display of the rating and review request view. Because calling this instance may not present an alert, don’t call it in response to a user action, such as a button tap.
  ///
  /// > When you call this instance while your app is in development mode, the system always displays a rating and review request view so you can test the user interface and experience. This instance has no effect when you call it in an app that you distribute using TestFlight.
  @available(iOS, deprecated: 16)
  @available(macOS, deprecated: 13)
  @MainActor public var requestReview: RequestReviewAction { .init() }
}

/// An instance that tells StoreKit to request an App Store rating or review from the user, if appropriate.
/// Read the requestReview environment value to get an instance of this structure for a given Environment. Call the instance to tell StoreKit to ask the user to rate or review your app, if appropriate. You call the instance directly because it defines a callAsFunction() method that Swift calls when you call the instance.
///
/// Although you normally call this instance to request a review when it makes sense in the user experience flow of your app, the App Store policy governs the actual display of the rating and review request view. Because calling this instance may not present an alert, don’t call it in response to a user action, such as a button tap.
///
/// > When you call this instance while your app is in development mode, the system always displays a rating and review request view so you can test the user interface and experience. This instance has no effect when you call it in an app that you distribute using TestFlight.
///
@available(iOS, deprecated: 16)
@available(macOS, deprecated: 13)
@MainActor public struct RequestReviewAction {
  public func callAsFunction() {
    #if os(macOS)
    SKStoreReviewController.requestReview()
    #else
    if #available(iOS 14, *) {
      guard let scene = UIApplication.activeScene else {
        return
      }
      SKStoreReviewController.requestReview(in: scene)
    } else {
      SKStoreReviewController.requestReview()
    }
    #endif
  }
}

#endif

#if canImport(iOS)

// MARK: - ShareButton

public struct ShareButton<ShareLabel: View>: View {
  // MARK: Lifecycle

  public init(
    item: String,
    @ViewBuilder _ label: @escaping () -> ShareLabel
  ) {
    self.item = item
    self.label = label
  }

  public init(
    item: String
  ) {
    self.item = item
    self.label = nil
  }

  // MARK: Public

  public var body: some View {
    Button {
      let AV = UIActivityViewController(activityItems: [item], applicationActivities: nil)
      let activeScene =
        UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive })
        as? UIWindowScene
      let rootViewController = (activeScene?.windows ?? []).first(where: { $0.isKeyWindow })?.rootViewController
      // for iPad. if condition is optional.
      if UIDevice.current.userInterfaceIdiom == .pad {
        AV.popoverPresentationController?.sourceView = rootViewController?.view
        AV.popoverPresentationController?.sourceRect = .zero
      }
      rootViewController?.present(AV, animated: true, completion: nil)

    } label: {
      if let label {
        label()
      } else {
        Image(systemName: "square.and.arrow.up")
      }
    }
  }

  // MARK: Internal

  @State var item: String
  var label: (() -> ShareLabel)?
}
#endif
