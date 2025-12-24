import Foundation

public struct YearGrid: Sendable, Equatable {
  public struct Configuration: Sendable, Equatable {
    public var filledSymbol: Character
    public var emptySymbol: Character
    public var todaySymbol: Character?
    public var showMonthLabels: Bool

    public init(
      filledSymbol: Character = "█",
      emptySymbol: Character = "░",
      todaySymbol: Character? = nil,
      showMonthLabels: Bool = false
    ) {
      self.filledSymbol = filledSymbol
      self.emptySymbol = emptySymbol
      self.todaySymbol = todaySymbol
      self.showMonthLabels = showMonthLabels
    }

    public static func modern() -> Self {
      Self(filledSymbol: "█", emptySymbol: "░")
    }

    public static func ascii() -> Self {
      Self(filledSymbol: "x", emptySymbol: "o")
    }
  }

  public let year: Int
  public let referenceDate: Date
  public let calendar: Calendar
  public let configuration: Configuration

  public init(
    year: Int,
    referenceDate: Date,
    calendar: Calendar,
    configuration: Configuration = .modern()
  ) {
    self.year = year
    self.referenceDate = referenceDate
    self.calendar = calendar
    self.configuration = configuration
  }

  public func render() -> String {
    var lines: [String] = []

    for month in 1...12 {
      var components = DateComponents(year: year, month: month, day: 1)
      components.calendar = calendar

      guard let firstOfMonth = calendar.date(from: components),
            let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
        continue
      }

      var line = ""

      if configuration.showMonthLabels {
        let monthSymbols = calendar.shortMonthSymbols
        let label = monthSymbols[month - 1]
        line += "\(label) "
      }

      for day in range {
        var dayComponents = DateComponents(year: year, month: month, day: day)
        dayComponents.calendar = calendar

        guard let dayDate = calendar.date(from: dayComponents) else { continue }

        let symbol: Character
        let startOfReferenceDay = calendar.startOfDay(for: referenceDate)

        if calendar.isDate(dayDate, inSameDayAs: referenceDate) {
          symbol = configuration.todaySymbol ?? configuration.filledSymbol
        } else if dayDate < startOfReferenceDay {
          symbol = configuration.filledSymbol
        } else {
          symbol = configuration.emptySymbol
        }

        line.append(symbol)
      }

      lines.append(line)
    }

    return lines.joined(separator: "\n")
  }
}
