import Foundation

public struct ProgressCalculator: Sendable {
  public let environment: Environment
  
  var calendar: Calendar { environment.calendar }
  var date: Date { environment.date }

  public init(environment: Environment) {
    self.environment = environment
  }
  
  func calculate(_ progress: ParsedArguments.Progress) throws(WhatProgressError) -> Double {
    switch progress {
    case .preset(let preset):
      switch preset {
      case .day:
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return 0.0 }
        return date.timeIntervalSince(startOfDay) / endOfDay.timeIntervalSince(startOfDay)
      case .week:
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date)
        else { return 0.0 }
        return date.timeIntervalSince(weekInterval.start) / weekInterval.duration
      case .month:
        guard let monthInterval = calendar.dateInterval(of: .month, for: date)
        else { return 0.0 }
        return date.timeIntervalSince(monthInterval.start) / monthInterval.duration
      case .year:
        guard let yearInterval = calendar.dateInterval(of: .year, for: date) else { return 0.0 }
        return date.timeIntervalSince(yearInterval.start) / yearInterval.duration
      case .life(let options):
        // Calculate the expected end of life date using calendar arithmetic
        guard let expectedEndDate = calendar.date(
          byAdding: .year,
          value: options.expectedLifespan,
          to: options.birthdate
        ) else { return 0.0 }
        return date.timeIntervalSince(options.birthdate)
        / expectedEndDate.timeIntervalSince(options.birthdate)
      }
    case .customRange(let range):
      return try range.parsedProgress
    }
  }
}

private extension ParsedArguments.Progress.CustomRange {
  var parsedProgress: Double {
    get throws(WhatProgressError) {
      guard end > start else { throw .invalidRange }
      return (current - start) / (end - start)
    }
  }
}
