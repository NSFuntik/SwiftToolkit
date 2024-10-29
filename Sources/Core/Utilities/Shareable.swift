import Combine
import Foundation
#if os(iOS)
  import SwiftUI

  /// A temporary protocol that defines requirements for shareable items.
  ///
  /// This protocol requires conforming types to provide a file path extension and an optional
  /// NSItemProvider for sharing content.
  ///
  /// - Note: This **will be removed** in an upcoming release, regardless of semantic versioning.
  @available(iOS, message: "This **will be removed** in an upcoming release, regardless of semantic versioning")
  @available(macOS, message: "This **will be removed** in an upcoming release, regardless of semantic versioning") public protocol Shareable {
    var pathExtension: String { get }
    var itemProvider: NSItemProvider? { get }
  }

  /// A wrapper struct that encapsulates a collection of shareable data items.
  ///
  /// - Parameter Data: A generic type constraint that allows any type that conforms to
  ///   `RandomAccessCollection` where its elements conform to the `Shareable` protocol.
  struct ActivityItem<Data> where Data: RandomAccessCollection, Data.Element: Shareable {
    var data: Data
  }

  public extension String {
    var pathExtensionTXT: String { "txt" }
    var itemProvider: NSItemProvider? {
      do {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
          .appendingPathComponent("\(LUUID().uuidString)")
          .appendingPathExtension(pathExtension)
        try write(to: url, atomically: true, encoding: .utf8)
        return .init(contentsOf: url)
      } catch {
        return nil
      }
    }
  }

  public extension URL {
    var itemProvider: NSItemProvider? {
      .init(contentsOf: self)
    }
  }

  public extension Image {
    var pathExtension: String { "jpg" }
    var itemProvider: NSItemProvider? {
      do {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
          .appendingPathComponent("\(LUUID().uuidString)")
          .appendingPathExtension(self.pathExtension)
        let renderer = ImageRenderer(content: self)
        #if os(iOS)
          let data = renderer.uiImage?.jpegData(compressionQuality: 0.8)
        #else
          let data = renderer.nsImage?.jpg(quality: 0.8)
        #endif
        try data?.write(to: url, options: .atomic)
        return .init(contentsOf: url)
      } catch {
        return nil
      }
    }
  }

  public extension UIImage {
    var pathExtension: String { "jpg" }
    var itemProvider: NSItemProvider? {
      do {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
          .appendingPathComponent("\(LUUID().uuidString)")
          .appendingPathExtension(self.pathExtension)
        let data = jpg(quality: 0.8)
        try data?.write(to: url, options: .atomic)
        return .init(contentsOf: url)
      } catch {
        return nil
      }
    }
  }

#elseif os(macOS)
  import AppKit

  public extension NSImage {
    var pathExtension: String { "jpg" }
    var itemProvider: NSItemProvider? {
      do {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
          .appendingPathComponent("\(LUUID().uuidString)")
          .appendingPathExtension(self.pathExtension)
        let data = jpg(quality: 0.8)
        try data?.write(to: url, options: .atomic)
        return .init(contentsOf: url)
      } catch {
        return nil
      }
    }
  }
#endif
#if os(iOS)
  import SwiftUI

  /// A structure representing a proposed size for a view.
  ///
  /// This structure can hold width and height values, allowing for dimensions to be defined as
  /// either fixed or flexible (unspecified). It also provides utility methods for dimension handling.
  @available(iOS, deprecated: 16.0) public struct ProposedViewSize: Equatable, Sendable {
    public var width: CGFloat?
    public var height: CGFloat?
    public static let zero = Self(width: 0, height: 0)
    public static let infinity = Self(width: .infinity, height: .infinity)
    public static let unspecified = Self(width: nil, height: nil)
    public init(_ size: CGSize) {
      self.width = size.width
      self.height = size.height
    }

    public init(width: CGFloat?, height: CGFloat?) {
      self.width = width
      self.height = height
    }

    /// Replace unspecified dimensions with given size values.
    ///
    /// - Parameter size: The size to use for replacing unspecified dimensions.
    /// - Returns: A CGSize where unspecified dimensions are replaced with the provided size.
    public func replacingUnspecifiedDimensions(by size: CGSize) -> CGSize {
      .init(
        width: self.width ?? size.width,
        height: self.height ?? size.height)
    }
  }

  /// A class responsible for rendering SwiftUI views as images.
  ///
  /// This class allows for configuration of rendering properties such as size, scale, and color mode.
  @available(iOS, deprecated: 16.0) public final class ImageRenderer<Content>: ObservableObject where Content: View {
    public var content: Content
    public var label: String?
    public var proposedSize: ProposedViewSize = .unspecified
    public var scale: CGFloat = UIScreen.mainScreen.scale
    public var isOpaque = false
    public var colorMode: ColorRenderingMode = .nonLinear
    public init(content: Content) {
      self.content = content
    }
  }

  public extension ImageRenderer {
    /// Retrieves the Core Graphics image representation of the rendered content.
    var cgImage: CGImage? {
      #if os(macOS)
        self.nsImage?.cgImage(forProposedRect: nil, context: .current, hints: nil)
      #else
        self.uiImage?.cgImage
      #endif
    }

    #if os(macOS)
      /// Retrieves the AppKit image representation of the rendered content.
      var nsImage: NSImage? {
        NSHostingController(rootView: self.content).view.snapshot
      }
    #else
      /// Retrieves the UIKit image representation of the rendered content.
      var uiImage: UIImage? {
        let controller = UIHostingController(rootView: content)
        let size = controller.view.intrinsicContentSize
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        let format = UIGraphicsImageRendererFormat(for: controller.traitCollection)
        format.opaque = self.isOpaque
        format.scale = self.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { context in
          controller.view.drawHierarchy(in: context.format.bounds, afterScreenUpdates: true)
        }
        image.accessibilityLabel = self.label
        objectWillChange.send()
        return image
      }
    #endif
  }

  #if os(iOS)
    public extension ColorRenderingMode {
      /// Maps the rendering mode to the corresponding range for UIGraphicsImageRenderer.
      var range: UIGraphicsImageRendererFormat.Range {
        switch self {
        case .extendedLinear: return .extended
        case .linear: return .standard
        default: return .automatic
        }
      }
    }
  #endif
  #if os(macOS)
    private extension NSView {
      /// Generates a snapshot of the view as an NSImage.
      var snapshot: NSImage? {
        return NSImage(data: dataWithPDF(inside: bounds))
      }
    }
  #endif
#endif
