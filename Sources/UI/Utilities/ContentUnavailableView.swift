import Core
import Photos
@_exported import SFSymbols
import SwiftUI

let cameraUnavailable =
  ContentUnavailableView(
    "Camera not avaible",
    message:
      "Camera not avaible. Please go to Settings > \(String(describing: Bundle.main.infoDictionary?["CFBundleName"])) > Camera",
    image: SFSymbol.questionmarkVideo.image,
    action: {
      PHPhotoLibrary.requestAuthorization { status in
        if status == .authorized {
          DispatchQueue.main.async {
            #if canImport(UIKit)
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            #endif
          }
        }
      }
    },
    content: {
      EmptyView()
    }
  )

#Preview(body: {
  cameraUnavailable
})

extension ContentUnavailableView where Content == EmptyView {
  /// Initializes a `ContentUnavailableView` with a title, subheadline, and a symbol.
  ///
  /// This initializer sets up the view to display a title text, a subheadline text,
  /// and an image represented by the provided `SFSymbol`.
  /// It also provides an action title and action symbol that can be used
  /// for a retry action.
  ///
  /// - Parameters:
  ///   - title: The title to be displayed in the view.
  ///   - subheadline: The subheadline message associated with the title.
  ///   - symbol: The `SFSymbol` that will be used as an image in the view.
  ///   - actionTitle: The title for the button action, default is "Retry".
  ///   - actionSymbol: The symbol for the action button, default is `.arrowClockwise`.
  ///   - action: A closure to be executed when the action button is tapped.
  public init(
    _ title: String,
    subheadline: String,
    symbol: SFSymbol,
    actionTitle: String = "Retry",
    actionSymbol: SFSymbol = .arrowClockwise,
    action: (() -> Void)? = nil
  ) where Content == EmptyView {
    self.title = title
    self.message = subheadline
    self.image = symbol.image
    self.content = nil
    self.actionTitle = actionTitle
    self.actionSymbol = actionSymbol
    self.action = action
  }

  /// Initializes a `ContentUnavailableView` with a title, subheadline, and an image.
  ///
  /// This initializer sets up the view to display a title text, a subheadline text,
  /// and an `Image`. It includes facilities to define the action button with its title
  /// and symbol for retrying the action.
  ///
  /// - Parameters:
  ///   - title: The title to be displayed in the view.
  ///   - subheadline: The subheadline message associated with the title.
  ///   - image: The `Image` that will be shown in the view.
  ///   - actionTitle: The title for the button action, default is "Retry".
  ///   - actionSymbol: The symbol for the action button, default is `.arrowClockwise`.
  ///   - action: A closure to be executed when the action button is tapped.
  public init(
    _ title: String,
    subheadline: String,
    image: Image,
    actionTitle: String = "Retry",
    actionSymbol: SFSymbol = .arrowClockwise,
    action: (() -> Void)? = nil
  ) where Content == EmptyView {
    self.title = title
    self.message = subheadline
    self.image = image
    self.content = nil
    self.actionTitle = actionTitle
    self.actionSymbol = actionSymbol
    self.action = action
  }
}

// MARK: - ContentUnavailableView

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 9.0, *)
public struct ContentUnavailableView<Content>: View where Content: View {
  let title: String
  let message: String
  let image: Image
  var content: (() -> Content)?
  var actionTitle = "Retry"
  var actionSymbol: SFSymbol = .arrowClockwise
  let action: (() -> Void)?
  @Environment(\.refresh) var refresh
  @Environment(\.dismiss) var dismiss
  /// Initializes a `ContentUnavailableView` with a title, subheadline, and an image.
  ///
  /// This initializer sets up the view to display a title text, a subheadline text,
  /// and an `Image`. It includes facilities to define the action button with its title
  /// and symbol for retrying the action.
  ///
  /// - Parameters:
  ///   - title: The title to be displayed in the view.
  ///   - subheadline: The subheadline message associated with the title.
  ///   - image: The `Image` that will be shown in the view.
  ///   - actionTitle: The title for the button action, default is "Retry".
  ///   - actionSymbol: The symbol for the action button, default is `.arrowClockwise`.
  ///   - action: A closure to be executed when the action button is tapped.
  ///   - content: A closure that returns the content view to be shown in the view.
  public init(
    _ title: String,
    message: String,
    image: Image,
    actionTitle: String = "Retry",
    actionSymbol: SFSymbol = .arrowClockwise,
    action: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.title = title
    self.message = message
    self.image = image
    self.content = content
    self.actionTitle = actionTitle
    self.actionSymbol = actionSymbol
    self.action = action
  }

  /// Initializes a `ContentUnavailableView` with a title, subheadline, and an image.
  ///
  /// This initializer sets up the view to display a title text, a subheadline text,
  /// and an `Image`. It includes facilities to define the action button with its title
  /// and symbol for retrying the action.
  ///
  /// - Parameters:
  ///   - title: The title to be displayed in the view.
  ///   - image: The `Image` that will be shown in the view.
  ///   - actionTitle: The title for the button action, default is "Retry".
  ///   - actionSymbol: The symbol for the action button, default is `.arrowClockwise`.
  ///   - action: A closure to be executed when the action button is tapped.
  ///   - content: A closure that returns the content view to be shown in the view.
  public init(
    _ title: String,
    image: SFSymbol,
    actionTitle: String = "Retry",
    actionSymbol: SFSymbol = .arrowClockwise,
    action: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.title = title
    self.message = ""
    self.image = image.image
    self.actionTitle = actionTitle
    self.actionSymbol = actionSymbol
    self.content = content
    self.action = action
  }

  public init(
    _ title: String,
    symbol: String,
    actionTitle: String = "Retry",
    actionSymbol: SFSymbol = .arrowClockwise,
    action: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.title = title
    self.message = ""
    self.image = Image(systemName: symbol)
    self.actionTitle = actionTitle
    self.actionSymbol = actionSymbol
    self.content = content
    self.action = action
  }

  public init(
    _ title: String,
    symbol: SFSymbol,
    description: String,
    actionTitle: String = "Retry",
    actionSymbol _: SFSymbol = .arrowClockwise,
    action: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.title = title
    self.message = description
    self.image = symbol.image
    self.content = content
    self.actionTitle = actionTitle
    self.action = action
  }

  public var body: some View {
    VStack(alignment: .center, spacing: 16) {
      image
        .font(.largeTitle)
        .imageScale(.large)
      if #available(macCatalyst 16.0, *) {
        Text(title)
          .font(.system(.title, .rounded, .bold))
          .multilineTextAlignment(.center).foregroundStyle(.primary)
      } else {
        // Fallback on earlier versions
        Text(title)
          .font(.system(.title, .rounded, .bold))
          .multilineTextAlignment(.center).foregroundStyle(.primary)
      }
      Text(message)
        .font(.system(.subheadline, .rounded, .medium))
        .multilineTextAlignment(.center).foregroundStyle(.secondary)
      content?()
      AsyncButton {
        if let action {
          action()
          return
        }
        await refresh?()
      } label: {
        Label(.init(actionTitle.isEmpty ? "Refresh" : actionTitle), symbol: actionSymbol)
          .font(.system(.headline, .rounded, .medium))
          .padding(2, 8)
      }
      .padding().buttonStyle(.refresh).clipped()
    }
    .padding().symbolRenderingMode(.hierarchical)
  }
}

#Preview(body: {
  ContentUnavailableView<Image>(
    "No Results",
    symbol: SFSymbol.battery100BoltRtl,
    description:
      "Content Unavailable View Decription \n In this implementation, the ContentUnavailableView is a generic view that takes a Content view as a trailing closure. It displays a title, message, and an image, along with the provided content view.",
    content: {
      SFSymbol.magnifyingglass.image
    }
  )
})
