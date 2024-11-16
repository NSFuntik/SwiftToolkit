//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 12.03.2024.
//

import AVFoundation

#if canImport(UIKit)
import UIKit
import SwiftUI

extension UIImage.Orientation {
  /// Initializes a UIImage.Orientation from a CGImagePropertyOrientation.
  /// - Parameter cgOrientation: The CGImagePropertyOrientation to convert.
  public init(_ cgOrientation: CGImagePropertyOrientation) {
    switch cgOrientation {
    case .up: self = .up
    case .upMirrored: self = .upMirrored
    case .down: self = .down
    case .downMirrored: self = .downMirrored
    case .left: self = .left
    case .leftMirrored: self = .leftMirrored
    case .right: self = .right
    case .rightMirrored: self = .rightMirrored
    }
  }
}

extension Image {
  /// This is a shorthand for `Image(systemName:)`.
  public static func system(_ name: String) -> Image {
    .init(systemName: name)
  }
}

extension UIImage {
  /// Fixes the orientation of the image to ensure it appears correctly.
  /// - Returns: A new UIImage instance with the fixed orientation.
  public func fixOrientation() -> UIImage {
    if imageOrientation == .up {
      return self
    }
    let format = UIGraphicsImageRendererFormat()
    format.opaque = true
    format.scale = scale
    return UIGraphicsImageRenderer(size: size, format: format).image { _ in
      self.draw(in: CGRect(origin: .zero, size: size))
    }
  }

  /// Scales the image to fill a target size while maintaining the aspect ratio.
  /// - Parameter targetSize: The desired size for the scaled image.
  /// - Returns: A new UIImage instance scaled to the specified size.
  public func scaleToFill(in targetSize: CGSize) -> UIImage {
    guard targetSize != .zero else {
      return self
    }
    let image = self
    let imageBounds = CGRect(origin: .zero, size: size)
    let cropRect = AVMakeRect(aspectRatio: targetSize, insideRect: imageBounds)
    let rendererFormat = UIGraphicsImageRendererFormat()
    rendererFormat.scale = 1
    let renderer = UIGraphicsImageRenderer(size: targetSize, format: rendererFormat)
    return renderer.image { context in
      // UIImage and CGContext coordinates are flipped.
      var transform = CGAffineTransform(translationX: 0.0, y: targetSize.height)
      transform = transform.scaledBy(x: 1, y: -1)
      context.cgContext.concatenate(transform)
      if let cgImage = image.cgImage?.cropping(to: cropRect) {
        context.cgContext.draw(cgImage, in: CGRect(origin: .zero, size: targetSize))
      }  // TODO: CIImage
    }
  }

  /// Creates an image with the proper orientation based on an AVCapturePhoto instance.
  /// - Parameter photo: The AVCapturePhoto instance used to create the UIImage.
  /// - Returns: A new UIImage instance, or nil if the image could not be created.
  public convenience init?(photo: AVFoundation.AVCapturePhoto) {
    guard let cgImage = photo.cgImageRepresentation(),
      let rawOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
      let cgOrientation = CGImagePropertyOrientation(rawValue: rawOrientation)
    else {
      return nil
    }
    let imageOrientation = UIImage.Orientation(cgOrientation)
    self.init(cgImage: cgImage, scale: 1, orientation: imageOrientation)
  }

  // MARK: - UIImage+Resize

  /// Resizes the image by a specified percentage.
  /// - Parameters:
  ///   - percentage: The percentage to resize the image (0.0 to 1.0).
  ///   - isOpaque: A Boolean value that determines whether the image is opaque.
  /// - Returns: A new UIImage instance or nil if the resizing fails.
  public func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
    let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
    let format = imageRendererFormat
    format.opaque = isOpaque
    return UIGraphicsImageRenderer(size: canvas, format: format).image {
      _ in draw(in: CGRect(origin: .zero, size: canvas))
    }
  }

  public var png: Data? { pngData() }
  public func jpg(quality: CGFloat) -> Data? { jpegData(compressionQuality: quality) }
}
#else
import AppKit

extension NSImage {
  func png() -> Data? { nil }
  func jpg(quality: CGFloat) -> Data? { nil }
}
#endif
