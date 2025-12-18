import Foundation

public struct Environment: Sendable {
  public var calendar: Calendar
  public var timeZone: TimeZone
  public var locale: Locale
  public var date: Date

  public init(
    calendar: Calendar = .autoupdatingCurrent,
    timeZone: TimeZone = .autoupdatingCurrent,
    locale: Locale = .autoupdatingCurrent,
    date: Date = .now
  ) {
    self.calendar = calendar
    self.timeZone = timeZone
    self.locale = locale
    self.date = date
  }

  @TaskLocal public static var current: Self = Self()
}
