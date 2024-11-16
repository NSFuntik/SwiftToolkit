//
//  Image+.swift
//  NSSwift
//
//  Created by Dmitry Mikhailov on 29.10.2024.
//
#if canImport(UIKit)
import UIKit

extension UIImage {
  /// Returns a formatted string representation of the image size in the specified data units.
  /// - Parameter units: The units to convert the image size into.
  /// - Returns: A string representation of the image size.
  public func getSizeString(in units: DataUnits) -> String {
    String(format: "%.2f", self.getSizeValue(in: units))
  }

  /// Calculates the size of the image in the specified data units.
  /// - Parameter type: The data unit type (e.g. bytes, kilobytes, megabytes, gigabytes).
  /// - Returns: The size of the image in the specified unit type.
  public func getSizeValue(in type: DataUnits) -> Double {
    guard let data = jpegData(compressionQuality: 1.0) else {
      return 0
    }
    var size = 0.0
    switch type {
    case .byte:
      size = Double(data.count)
    case .kilobyte:
      size = Double(data.count) / 1024
    case .megabyte:
      size = Double(data.count) / 1024 / 1024
    case .gigabyte:
      size = Double(data.count) / 1024 / 1024 / 1024
    }
    return size
  }
}
#else
import AppKit

extension NSImage {
  /// Returns a formatted string representation of the image size in the specified data units.
  /// - Parameter units: The units to convert the image size into.
  /// - Returns: A string representation of the image size.
  public func getSizeString(in units: DataUnits) -> String {
    String(format: "%.2f", self.getSizeValue(in: units))
  }

  /// Calculates the size of the image in the specified data units.
  /// - Parameter type: The data unit type (e.g. bytes, kilobytes, megabytes, gigabytes).
  /// - Returns: The size of the image in the specified unit type.
  public func getSizeValue(in type: DataUnits) -> Double {
    guard let data = jpegData(compressionQuality: 1.0) else {
      return 0
    }
    var size = 0.0
    switch type {
    case .byte:
      size = Double(data.count)
    case .kilobyte:
      size = Double(data.count) / 1024
    case .megabyte:
      size = Double(data.count) / 1024 / 1024
    case .gigabyte:
      size = Double(data.count) / 1024 / 1024 / 1024
    }
    return size
  }
}

extension NSImage {
  public func jpegData(compressionQuality: CGFloat) -> Data? {
    guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
      return nil
    }

    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
  }

  public var cgImage: CGImage? {
    cgImage(forProposedRect: nil, context: nil, hints: nil)
  }

  public convenience init?(data: Data) {
    self.init(dataIgnoringOrientation: data)
  }
}

#endif
