import Foundation

public struct Environment: Sendable {
  public typealias Printer = @Sendable (String) -> Void
  public var calendar: Calendar
  public var timeZone: TimeZone
  public var locale: Locale
  public var date: Date
  public var print: Printer
  
  public init(
    calendar: Calendar = .autoupdatingCurrent,
    timeZone: TimeZone = .autoupdatingCurrent,
    locale: Locale = .autoupdatingCurrent,
    date: Date = .now,
    print: @escaping Printer = { Swift.print($0) }
  ) {
    self.calendar = calendar
    self.timeZone = timeZone
    self.locale = locale
    self.date = date
    self.print = print
  }
  
  @TaskLocal public static var current: Self = Self()
}
