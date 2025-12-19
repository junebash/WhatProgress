import Foundation
import Testing

@testable import WhatProgressCore

@Suite("Progress Calculator")
struct ProgressCalculatorTests {

  // MARK: - Day Progress

  @Test("day progress at midnight is 0%")
  func dayProgressAtMidnight() {
    let env = makeEnvironment(hour: 0, minute: 0, second: 0)
    let calc = ProgressCalculator(environment: env)
    #expect(calc.dayProgress() == 0.0)
  }

  @Test("day progress at noon is ~50%")
  func dayProgressAtNoon() {
    let env = makeEnvironment(hour: 12, minute: 0, second: 0)
    let calc = ProgressCalculator(environment: env)
    #expect(calc.dayProgress() == 0.5)
  }

  @Test("day progress at 6pm is 75%")
  func dayProgressAt6pm() {
    let env = makeEnvironment(hour: 18, minute: 0, second: 0)
    let calc = ProgressCalculator(environment: env)
    #expect(calc.dayProgress() == 0.75)
  }

  @Test("day progress at 23:59:59 is nearly 100%")
  func dayProgressAtEndOfDay() {
    let env = makeEnvironment(hour: 23, minute: 59, second: 59)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.dayProgress()
    #expect(progress > 0.99)
    #expect(progress < 1.0)
  }

  // MARK: - Week Progress

  @Test("week progress at start of week is 0%")
  func weekProgressAtStart() {
    // Create an environment at the very start of the week (Sunday Dec 14, 2025)
    let calendar = makeTestCalendar()
    var components = DateComponents(
      year: 2025, month: 12, day: 14,
      hour: 0, minute: 0, second: 0
    )
    components.timeZone = Self.testTimeZone
    let startOfWeek = calendar.date(from: components)!

    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: startOfWeek)
    let calc = ProgressCalculator(environment: env)
    #expect(calc.weekProgress() == 0.0)
  }

  @Test("week progress mid-week is approximately 50%")
  func weekProgressMidWeek() {
    // Wednesday noon in a Sunday-start week
    let calendar = makeTestCalendar()

    // Sunday + 3.5 days = Wednesday noon
    var components = DateComponents(
      year: 2025, month: 12, day: 17, // A Wednesday
      hour: 12, minute: 0, second: 0
    )
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!

    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: date)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.weekProgress()
    #expect(progress > 0.45 && progress < 0.55)
  }

  // MARK: - Month Progress

  @Test("month progress on first day at midnight is 0%")
  func monthProgressAtStart() {
    let calendar = makeTestCalendar()
    var components = DateComponents(
      year: 2025, month: 12, day: 1,
      hour: 0, minute: 0, second: 0
    )
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!
    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: date)
    let calc = ProgressCalculator(environment: env)
    #expect(calc.monthProgress() == 0.0)
  }

  @Test("month progress mid-month is approximately 50%")
  func monthProgressMidMonth() {
    // December has 31 days, so day 16 at noon should be ~50%
    let calendar = makeTestCalendar()
    var components = DateComponents(
      year: 2025, month: 12, day: 16,
      hour: 12, minute: 0, second: 0
    )
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!
    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: date)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.monthProgress()
    #expect(progress > 0.45 && progress < 0.55)
  }

  // MARK: - Year Progress

  @Test("year progress on Jan 1 at midnight is 0%")
  func yearProgressAtStart() {
    let calendar = makeTestCalendar()
    var components = DateComponents(
      year: 2025, month: 1, day: 1,
      hour: 0, minute: 0, second: 0
    )
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!
    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: date)
    let calc = ProgressCalculator(environment: env)
    #expect(calc.yearProgress() == 0.0)
  }

  @Test("year progress mid-year is approximately 50%")
  func yearProgressMidYear() {
    // July 2 at noon is approximately mid-year
    let calendar = makeTestCalendar()
    var components = DateComponents(
      year: 2025, month: 7, day: 2,
      hour: 12, minute: 0, second: 0
    )
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!
    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: date)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.yearProgress()
    #expect(progress > 0.45 && progress < 0.55)
  }

  // MARK: - Lifetime Progress

  @Test("lifetime progress for 50-year-old with 100-year lifespan is ~50%")
  func lifetimeProgressAt50() {
    let calendar = makeTestCalendar()
    var birthComponents = DateComponents(year: 1975, month: 6, day: 15)
    birthComponents.timeZone = Self.testTimeZone
    var currentComponents = DateComponents(year: 2025, month: 6, day: 15)
    currentComponents.timeZone = Self.testTimeZone

    let birthdate = calendar.date(from: birthComponents)!
    let currentDate = calendar.date(from: currentComponents)!

    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: currentDate)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.lifetimeProgress(birthdate: birthdate, expectedLifespan: 100)
    // Not exactly 0.5 due to leap year distribution across the lifespan
    #expect(progress > 0.499 && progress < 0.501)
  }

  @Test("lifetime progress can exceed 100% if older than expected lifespan")
  func lifetimeProgressOverflow() {
    let calendar = makeTestCalendar()
    var birthComponents = DateComponents(year: 1920, month: 1, day: 1)
    birthComponents.timeZone = Self.testTimeZone
    var currentComponents = DateComponents(year: 2025, month: 1, day: 1)
    currentComponents.timeZone = Self.testTimeZone

    let birthdate = calendar.date(from: birthComponents)!
    let currentDate = calendar.date(from: currentComponents)!

    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: currentDate)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.lifetimeProgress(birthdate: birthdate, expectedLifespan: 100)
    #expect(progress > 1.0) // 105 years old
  }

  @Test("lifetime progress with custom lifespan")
  func lifetimeProgressCustomLifespan() {
    let calendar = makeTestCalendar()
    var birthComponents = DateComponents(year: 2000, month: 1, day: 1)
    birthComponents.timeZone = Self.testTimeZone
    var currentComponents = DateComponents(year: 2025, month: 1, day: 1)
    currentComponents.timeZone = Self.testTimeZone

    let birthdate = calendar.date(from: birthComponents)!
    let currentDate = calendar.date(from: currentComponents)!

    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: currentDate)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.lifetimeProgress(birthdate: birthdate, expectedLifespan: 50)
    // 25 years old, 50 year lifespan - not exactly 0.5 due to leap year distribution
    #expect(progress > 0.499 && progress < 0.501)
  }

  // MARK: - Calculate (main switch method)

  @Test("calculate with day preset")
  func calculateDayPreset() throws {
    let calc = ProgressCalculator(environment: makeEnvironment(hour: 12, minute: 0, second: 0))
    let progress = try calc.calculate(.preset(.day))
    #expect(progress == 0.5)
  }

  @Test("calculate with week preset")
  func calculateWeekPreset() throws {
    let calendar = makeTestCalendar()
    var components = DateComponents(
      year: 2025, month: 12, day: 17,
      hour: 12, minute: 0, second: 0
    )
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!
    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: date)
    let calc = ProgressCalculator(environment: env)
    let progress = try calc.calculate(.preset(.week))
    #expect(progress > 0.45 && progress < 0.55)
  }

  @Test("calculate with month preset")
  func calculateMonthPreset() throws {
    let calendar = makeTestCalendar()
    var components = DateComponents(
      year: 2025, month: 12, day: 16,
      hour: 12, minute: 0, second: 0
    )
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!
    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: date)
    let calc = ProgressCalculator(environment: env)
    let progress = try calc.calculate(.preset(.month))
    #expect(progress > 0.45 && progress < 0.55)
  }

  @Test("calculate with year preset")
  func calculateYearPreset() throws {
    let calendar = makeTestCalendar()
    var components = DateComponents(
      year: 2025, month: 7, day: 2,
      hour: 12, minute: 0, second: 0
    )
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!
    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: date)
    let calc = ProgressCalculator(environment: env)
    let progress = try calc.calculate(.preset(.year))
    #expect(progress > 0.45 && progress < 0.55)
  }

  @Test("calculate with life preset")
  func calculateLifePreset() throws {
    let calendar = makeTestCalendar()
    var birthComponents = DateComponents(year: 1975, month: 6, day: 15)
    birthComponents.timeZone = Self.testTimeZone
    var currentComponents = DateComponents(year: 2025, month: 6, day: 15)
    currentComponents.timeZone = Self.testTimeZone

    let birthdate = calendar.date(from: birthComponents)!
    let currentDate = calendar.date(from: currentComponents)!

    let env = Environment(calendar: calendar, timeZone: Self.testTimeZone, date: currentDate)
    let calc = ProgressCalculator(environment: env)

    let options = ParsedArguments.Progress.LifetimeOptions(
      birthdate: birthdate,
      expectedLifespan: 100
    )
    let progress = try calc.calculate(.preset(.life(options)))
    // Not exactly 0.5 due to leap year distribution across the lifespan
    #expect(progress > 0.499 && progress < 0.501)
  }

  @Test("calculate with custom range")
  func calculateCustomRange() throws {
    let calc = ProgressCalculator(environment: makeEnvironment(hour: 12, minute: 0, second: 0))
    let range = makeRange(start: 0, current: 50, end: 100)
    let progress = try calc.calculate(.customRange(range))
    #expect(progress == 0.5)
  }

  @Test("calculate with custom range throws for invalid range")
  func calculateCustomRangeInvalid() throws {
    let calc = ProgressCalculator(environment: makeEnvironment(hour: 12, minute: 0, second: 0))
    let range = makeRange(start: 100, current: 50, end: 50)
    do {
      _ = try calc.calculate(.customRange(range))
      Issue.record("Expected invalidRange error to be thrown")
    } catch {
      guard case .invalidRange = error else {
        Issue.record("Expected invalidRange but got \(error)")
        return
      }
    }
  }

  // MARK: - Custom Progress

  @Test("custom progress basic calculation")
  func customProgressBasic() throws {
    let calc = ProgressCalculator(environment: makeEnvironment(hour: 12, minute: 0, second: 0))
    let progress = try calc.customProgress(makeRange(start: 0, current: 50, end: 100))
    #expect(progress == 0.5)
  }

  @Test("custom progress at start")
  func customProgressAtStart() throws {
    let calc = ProgressCalculator(environment: makeEnvironment(hour: 12, minute: 0, second: 0))
    let progress = try calc.customProgress(makeRange(start: 10, current: 10, end: 100))
    #expect(progress == 0.0)
  }

  @Test("custom progress at end")
  func customProgressAtEnd() throws {
    let calc = ProgressCalculator(environment: makeEnvironment(hour: 12, minute: 0, second: 0))
    let progress = try calc.customProgress(makeRange(start: 0, current: 100, end: 100))
    #expect(progress == 1.0)
  }

  @Test("custom progress can exceed 100%")
  func customProgressOverflow() throws {
    let calc = ProgressCalculator(environment: makeEnvironment(hour: 12, minute: 0, second: 0))
    let progress = try calc.customProgress(makeRange(start: 0, current: 150, end: 100))
    #expect(progress == 1.5)
  }

  @Test("custom progress below start returns negative")
  func customProgressUnderflow() throws {
    let calc = ProgressCalculator(environment: makeEnvironment(hour: 12, minute: 0, second: 0))
    let progress = try calc.customProgress(makeRange(start: 50, current: 25, end: 100))
    #expect(progress == -0.5) // current < start yields negative progress
  }

  @Test("custom progress throws for invalid range")
  func customProgressInvalidRange() throws {
    let calc = ProgressCalculator(environment: makeEnvironment(hour: 12, minute: 0, second: 0))
    do {
      _ = try calc.customProgress(makeRange(start: 100, current: 50, end: 50))
      Issue.record("Expected invalidRange error to be thrown")
    } catch {
      guard case .invalidRange = error else {
        Issue.record("Expected invalidRange but got \(error)")
        return
      }
    }
  }

  // MARK: - Helpers

  /// Fixed timezone for deterministic tests
  private static let testTimeZone = TimeZone(identifier: "America/Los_Angeles")!

  /// Creates a calendar configured for deterministic testing
  private func makeTestCalendar() -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = Self.testTimeZone
    calendar.locale = Locale(identifier: "en_US")
    calendar.firstWeekday = 1 // Sunday
    return calendar
  }

  private func makeEnvironment(hour: Int, minute: Int, second: Int) -> Environment {
    let calendar = makeTestCalendar()
    var components = DateComponents(
      year: 2025, month: 12, day: 18,
      hour: hour, minute: minute, second: second
    )
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!
    return Environment(calendar: calendar, timeZone: Self.testTimeZone, date: date)
  }

  private func makeRange(
    start: Double,
    current: Double,
    end: Double
  ) -> ParsedArguments.Progress.CustomRange {
    ParsedArguments.Progress.CustomRange(start: start, current: current, end: end)
  }
}
