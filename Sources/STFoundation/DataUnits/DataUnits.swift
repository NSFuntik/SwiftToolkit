//
//  File.swift
//
//
//  Created by Dmitry Mikhaylov on 16.04.2024.
//
#if canImport(UIKit)
  import UIKit

#endif

// MARK: - DataUnits

public enum DataUnits: String {
  case byte, kilobyte, megabyte, gigabyte

  // Nested Types

  public typealias Value = Double
  public typealias Unit = (size: Double, unit: Self)

  // Computed Properties

  public var bytes: Value {
    switch self {
    case .byte:
      1
    case .kilobyte:
      1024
    case .megabyte:
      1024 * 1024
    case .gigabyte:
      1024 * 1024 * 1024
    }
  }

  // Static Functions

  public static func getInBytes(from unit: Unit) -> Value {
    unit.size * unit.unit.bytes
  }
}

public extension UInt64 {
  func getSizeIn(_ type: DataUnits) -> String {
    var size = 0.0
    switch type {
    case .byte:
      size = Double(self)
    case .kilobyte:
      size = Double(self) / 1024
    case .megabyte:
      size = Double(self) / 1024 / 1024
    case .gigabyte:
      size = Double(self) / 1024 / 1024 / 1024
    }
    return String(format: "%.0f", size)
  }
}
