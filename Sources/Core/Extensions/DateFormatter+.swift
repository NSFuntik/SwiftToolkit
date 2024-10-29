
#if canImport(UIKit)
  import UIKit
#else
  import AppKit
#endif
public extension ISO8601DateFormatter {
  /// A full ISO8601 date formatter that includes fractional seconds and full date with internet date-time.
  static var full: ISO8601DateFormatter {
    let isoDateFormatter = ISO8601DateFormatter()
    isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withFullDate]
    isoDateFormatter.timeZone = .autoupdatingCurrent
    return isoDateFormatter
  }
}

public extension DateFormatter {
  /// Initializes a `DateFormatter` with a given date format. Defaults to an ISO8601 string representation of the current date and time.
  convenience init(dateFormat: String = ISO8601DateFormatter.string(from: .now, timeZone: .autoupdatingCurrent)) {
    self.init()
    locale = Locale.current
    self.dateFormat = dateFormat
  }

  /// A static property that provides a `DateFormatter` configured to display short time.
  static let timeFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
  }()

  /// A static property that provides a `DateFormatter` for displaying relative dates.
  static let relativeDateFormatter = {
    let relativeDateFormatter = DateFormatter()
    relativeDateFormatter.timeStyle = .none
    relativeDateFormatter.dateStyle = .full
    relativeDateFormatter.locale = Locale.autoupdatingCurrent
    relativeDateFormatter.doesRelativeDateFormatting = true
    return relativeDateFormatter
  }()

  /// Converts a given number of seconds into a time string of format "HH:mm:ss" or "MM:ss".
  static func timeString(_ seconds: Int) -> String {
    let hour = Int(seconds) / 3600
    let minute = Int(seconds) / 60 % 60
    let second = Int(seconds) % 60
    if hour > 0 {
      return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    return String(format: "%02i:%02i", minute, second)
  }
}

public extension Date {
  /// Initializes a `Date` from a string using a specified format or a default ISO8601 format. Throws an error if the date cannot be parsed.
  init?(
    string dateString: String?,
    format: String? = nil) throws {
    guard let dateString, let format else {
      throw CocoaError(.coderValueNotFound)
    }
    if let date = DateFormatter(dateFormat: format).date(from: dateString) {
      self = date
    } else if let date = DateFormatter(dateFormat: "yyyy-MM-ddTHH:mm:ssZ").date(from: dateString) {
      self = date
    } else {
      do {
        let isoDate = try ISO8601FormatStyle().parse(dateString)
        self = isoDate
      } catch {
        throw error
      }
    }
  }

  /// A string representation of the date in ISO8601 format.
  var string: String {
    let string = ISO8601DateFormatter.full.string(from: self)
    debugPrint(string)
    return string
  }

  /// A string representation of the current time in "HH:mm" format.
  var time: String {
    let format = "HH:mm"
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.dateFormat = format
    let string = formatter.string(from: Date.now)
    debugPrint(string)
    return string
  }
}

public extension Date {
  /// Returns the difference in a specific calendar component between the date and another date.
  func fullDistance(
    from date: Date,
    resultIn component: Calendar.Component,
    calendar: Calendar = .current) -> Int? {
    calendar.dateComponents([component], from: self, to: date).value(for: component)
  }

  /// Calculates the distance between two dates in specified calendar component.
  func distance(
    from date: Date,
    only component: Calendar.Component,
    calendar: Calendar = .current) -> Int {
    let days1 = calendar.component(component, from: self)
    let days2 = calendar.component(component, from: date)
    return days1 - days2
  }

  /// Checks if a specific calendar component of the date is the same as another date.
  func hasSame(
    _ component: Calendar.Component,
    as date: Date) -> Bool {
    distance(from: date, only: component) == 0
  }
}

public extension Date {
  /// Timestamp in milliseconds since January 1, 1970.
  var timestamp: Int64 {
    return Int64(self.timeIntervalSince1970 * 1000)
  }

  /// Current timestamp in milliseconds since January 1, 1970.
  static var currentTimeStamp: Int64 {
    return Int64(Date().timeIntervalSince1970 * 1000)
  }
}
