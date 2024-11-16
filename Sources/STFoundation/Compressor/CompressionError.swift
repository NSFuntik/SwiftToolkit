//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 15.04.2024.
//

import Foundation

public enum CompressionError: Error {
  case invalidImage
  case fileSizeExceeded
  case savingFailed(Error)
  case invalidFilePath(String)
  case accessRestricted
  /**
   The error received when trying to compress/decompress empty data (when length equals zero).
   */
  case emptyData

  /**
   The error received when `compression_stream_init` failed. It also fails when trying to decompress `Data` compressed with different compression algorithm or uncompressed raw data.
   */
  case initError

  /**
   The error received when `compression_stream_process` failed.
   */
  case processError
  case compressionFailed(_ desctiption: String = "Compression failed")

  public var localizedDescription: String {
    return switch self {
    case .emptyData: "The error received when trying to compress/decompress empty data (when length equals zero)."

    case .initError:
      "The error received when `compression_stream_init` failed. It also fails when trying to decompress `Data` compressed with different compression algorithm or uncompressed raw data."

    case .processError: "The error received when `compression_stream_process` failed."

    case let .compressionFailed(desctiption): desctiption

    case .invalidImage: "Invalid image"

    case .fileSizeExceeded: "File size exceeded"

    case let .savingFailed(error): "Error saving file: \(error.localizedDescription)"

    case let .invalidFilePath(url): "Invalid file path \(url)"

    case .accessRestricted: "Access restricted"
    }
  }
}
