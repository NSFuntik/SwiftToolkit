import Foundation

public extension TimeInterval {
  /**
   Creates a new `TimeInterval` from the given number of nanoseconds.
   - Parameter nanoseconds: The number of nanoseconds.
   */
  init(nanoseconds: Double) { self = nanoseconds / 1_000_000_000 }

  /**
   Creates a new `TimeInterval` from the given number of microseconds.
   - Parameter microseconds: The number of microseconds.
   */
  init(microseconds: Double) { self = microseconds / 1_000_000 }

  /**
   Creates a new `TimeInterval` from the given number of milliseconds.
   - Parameter milliseconds: The number of milliseconds.
   */
  init(milliseconds: Double) { self = milliseconds / 1000 }

  /**
   Creates a new `TimeInterval` from the given number of seconds.
   - Parameter seconds: The number of seconds.
   */
  init(seconds: Double) { self = seconds }

  /**
   Creates a new `TimeInterval` from the given number of minutes.
   - Parameter minutes: The number of minutes.
   */
  init(minutes: Double) { self = minutes * 60 }

  /**
   Creates a new `TimeInterval` from the given number of hours.
   - Parameter hours: The number of hours.
   */
  init(hours: Double) { self = hours * 3600 }

  /**
   The number of nanoseconds in the `TimeInterval`.
   */
  var nanoseconds: UInt64 { UInt64(self * 1_000_000_000) }

  /**
   The number of microseconds in the `TimeInterval`.
   */
  var microseconds: Double { self * 1_000_000 }

  /**
   The number of milliseconds in the `TimeInterval`.
   */
  var milliseconds: Double { self * 1000 }

  /**
   The number of seconds in the `TimeInterval`.
   */
  var seconds: Double { self }

  /**
   The number of minutes in the `TimeInterval`.
   */
  var minutes: Double { self / 60 }

  /**
   The number of hours in the `TimeInterval`.
   */
  var hours: Double { self / 3600 }

  /**
   Covert the `TimeInterval` to a string.
   The string will be in the format `[h]h [m]m [s]s`.
   Only the largest unit of time will be displayed.
   */
  var timeString: String {
    let days = Int(self / 86400)
    var n = Int(self) % 86400
    let hours = Int(n / 3600)
    n = n % 3600
    let minutes = Int(n / 60)
    let seconds = n % 60
    if days > 0 {
      return "\(days)d \(hours)h \(minutes)m \(seconds)s"
    } else if hours > 0 {
      return "\(hours)h \(minutes)m \(seconds)s"
    } else if minutes > 0 {
      return "\(minutes)m \(seconds)s"
    } else {
      return "\(seconds)s"
    }
  }
}
