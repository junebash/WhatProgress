import Foundation

public struct ProgressCalculator: Sendable {
  public let environment: Environment

  public init(environment: Environment = .current) {
    self.environment = environment
  }

  /// Calculate progress through the current day (midnight to midnight)
  public func dayProgress() -> Double {
    let calendar = environment.calendar
    let date = environment.date

    let startOfDay = calendar.startOfDay(for: date)
    let secondsSinceMidnight = date.timeIntervalSince(startOfDay)
    let secondsInDay: Double = 24 * 60 * 60

    return secondsSinceMidnight / secondsInDay
  }

  /// Calculate progress through the current week (locale-aware start day)
  public func weekProgress() -> Double {
    let calendar = environment.calendar
    let date = environment.date

    guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start else {
      return 0.0
    }

    let secondsSinceWeekStart = date.timeIntervalSince(startOfWeek)
    let secondsInWeek: Double = 7 * 24 * 60 * 60

    return secondsSinceWeekStart / secondsInWeek
  }

  /// Calculate progress through the current month
  public func monthProgress() -> Double {
    let calendar = environment.calendar
    let date = environment.date

    guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
      return 0.0
    }

    let secondsSinceMonthStart = date.timeIntervalSince(monthInterval.start)
    let secondsInMonth = monthInterval.duration

    return secondsSinceMonthStart / secondsInMonth
  }

  /// Calculate progress through the current year
  public func yearProgress() -> Double {
    let calendar = environment.calendar
    let date = environment.date

    guard let yearInterval = calendar.dateInterval(of: .year, for: date) else {
      return 0.0
    }

    let secondsSinceYearStart = date.timeIntervalSince(yearInterval.start)
    let secondsInYear = yearInterval.duration

    return secondsSinceYearStart / secondsInYear
  }

  /// Calculate progress through lifetime from birthdate to expected lifespan
  public func lifetimeProgress(birthdate: Date, expectedLifespan: Int = 100) -> Double {
    let calendar = environment.calendar
    let date = environment.date

    let ageComponents = calendar.dateComponents([.year, .month, .day], from: birthdate, to: date)
    let years = Double(ageComponents.year ?? 0)
    let months = Double(ageComponents.month ?? 0)
    let days = Double(ageComponents.day ?? 0)

    // Approximate age in years
    let ageInYears = years + (months / 12.0) + (days / 365.0)

    return ageInYears / Double(expectedLifespan)
  }

  /// Calculate custom progress from start to end
  public static func customProgress(start: Double, current: Double, end: Double) -> Double {
    guard end > start else {
      return 0.0
    }

    let progress = (current - start) / (end - start)

    // Clamp underflow to 0, but allow overflow
    return max(0.0, progress)
  }
}
