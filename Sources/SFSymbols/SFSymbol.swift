#if canImport(UIKit)
  import UIKit
#else
  import AppKit
#endif
import SwiftUI

public extension SFSymbol {
  static func symbol(forFileURL fileURL: URL) -> SFSymbol {
    let fileExtension = fileURL.pathExtension.lowercased()

    return switch fileExtension {
    case "doc",
         "docx": .docFill
    case "xls",
         "xlsx": .tablecellsFill
    case "ppt",
         "pptx": .rectangleFillOnRectangleAngledFill
    case "pdf": .docRichtextFill
    case "txt": .textAlignleft
    case "jpeg",
         "jpg": .photoFill
    case "png": .photoOnRectangleAngled
    case "gif": .livephoto
    case "mp3": .musicQuarternote3
    case "wav": .waveformPathEcg
    case "mov",
         "mp4": .filmFill
    case "rar",
         "zip": .archiveboxFill
    case "html": .scrollFill
    default: .folderBadgeQuestionmark
    }
  }

  /// Находит символ, наиболее похожий на заданную входную строку.
  /// Этот метод просматривает все значения `SFSymbol`, чтобы найти символ
  /// имя которого имеет минимальное расстояние Левенштейна до входной строки.
  ///
  /// - Ввод параметра: строка для сравнения с именами символов.
  /// - Возвращает: `SFSymbol`, наиболее похожий на предоставленную входную строку.
  /// Возвращает `nil`, если нет символов (маловероятно в практических сценариях).
  @Sendable static func findSymbol(by input: String) async -> Image? {
    guard input.isEmpty == false else {
      return nil
    }

    #if os(macOS)
      if let resource = NSImageResource(name: input, bundle: Bundle(for: MLSymbolFinder.self))?.uiImage() {
        return Image(nsImage: resource)
      }

    #else
      if let resource = NSImageResource(name: input, bundle: Bundle(for: MLSymbolFinder.self))?.uiImage() {
        return Image(uiImage: resource)
      }
    #endif

    return await Task(priority: .utility) { () async -> SFSymbol? in await MLSymbolFinder.findMostSimilarSymbol(to: input) }.value?.image
  }
}

// MARK: - NSImageResource

// An image resource.

@available(iOS, deprecated: 16)
@available(watchOS, unavailable)
public struct NSImageResource: Hashable {
  // Properties

  /// An asset catalog image resource name. fileprivate let name: String
  fileprivate let name: String
  /// An asset catalog image resource bundle. fileprivate let bundle: Bundle
  fileprivate let bundle: Bundle

  // Lifecycle

  public init?(name: String, bundle: Bundle) {
    self.name = name

    self.bundle = bundle
  }

  // Functions

  // Methods
  #if canImport(UIKit)

    public func uiImage() -> UIImage? {
      UIImage(named: self.name, in: self.bundle, compatibleWith: .current)
    }
  #else
    public func uiImage() -> NSImage? {
      NSImage(named: self.name)
    }
  #endif
}

//

//

//

//

@available(iOS, deprecated: 16)
@available(watchOS, unavailable)
extension NSImageResource {
  init?(_ thinnableName: String, bundle: Bundle = Bundle(for: MLSymbolFinder.self)) {
    #if canImport(AppKit) && os(macOS)
      if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
        self.init(name: thinnableName, bundle: bundle)
      } else {
        return nil
      }
    #elseif canImport(UIKit) && !os(watchOS)
      if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: .current) != nil {
        self.init(name: thinnableName, bundle: bundle)
      } else {
        return nil
      }
    #else
      return nil
    #endif
  }
}
