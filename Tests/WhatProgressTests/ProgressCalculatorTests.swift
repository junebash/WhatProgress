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
    var calendar = Calendar(identifier: .gregorian)
    calendar.firstWeekday = 1 // Sunday
    let components = DateComponents(
      year: 2025, month: 12, day: 14,
      hour: 0, minute: 0, second: 0
    )
    let startOfWeek = calendar.date(from: components)!

    let env = Environment(calendar: calendar, date: startOfWeek)
    let calc = ProgressCalculator(environment: env)
    #expect(calc.weekProgress() == 0.0)
  }

  @Test("week progress mid-week is approximately 50%")
  func weekProgressMidWeek() {
    // Wednesday noon in a Sunday-start week
    var calendar = Calendar(identifier: .gregorian)
    calendar.firstWeekday = 1 // Sunday

    // Sunday + 3.5 days = Wednesday noon
    let components = DateComponents(
      year: 2025, month: 12, day: 17, // A Wednesday
      hour: 12, minute: 0, second: 0
    )
    let date = calendar.date(from: components)!

    let env = Environment(calendar: calendar, date: date)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.weekProgress()
    #expect(progress > 0.45 && progress < 0.55)
  }

  // MARK: - Month Progress

  @Test("month progress on first day at midnight is 0%")
  func monthProgressAtStart() {
    let components = DateComponents(
      year: 2025, month: 12, day: 1,
      hour: 0, minute: 0, second: 0
    )
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: components)!
    let env = Environment(calendar: calendar, date: date)
    let calc = ProgressCalculator(environment: env)
    #expect(calc.monthProgress() == 0.0)
  }

  @Test("month progress mid-month is approximately 50%")
  func monthProgressMidMonth() {
    // December has 31 days, so day 16 at noon should be ~50%
    let components = DateComponents(
      year: 2025, month: 12, day: 16,
      hour: 12, minute: 0, second: 0
    )
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: components)!
    let env = Environment(calendar: calendar, date: date)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.monthProgress()
    #expect(progress > 0.45 && progress < 0.55)
  }

  // MARK: - Year Progress

  @Test("year progress on Jan 1 at midnight is 0%")
  func yearProgressAtStart() {
    let components = DateComponents(
      year: 2025, month: 1, day: 1,
      hour: 0, minute: 0, second: 0
    )
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: components)!
    let env = Environment(calendar: calendar, date: date)
    let calc = ProgressCalculator(environment: env)
    #expect(calc.yearProgress() == 0.0)
  }

  @Test("year progress mid-year is approximately 50%")
  func yearProgressMidYear() {
    // July 2 at noon is approximately mid-year
    let components = DateComponents(
      year: 2025, month: 7, day: 2,
      hour: 12, minute: 0, second: 0
    )
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: components)!
    let env = Environment(calendar: calendar, date: date)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.yearProgress()
    #expect(progress > 0.45 && progress < 0.55)
  }

  // MARK: - Lifetime Progress

  @Test("lifetime progress for 50-year-old with 100-year lifespan is 50%")
  func lifetimeProgressAt50() {
    let calendar = Calendar(identifier: .gregorian)
    let birthdate = calendar.date(from: DateComponents(year: 1975, month: 6, day: 15))!
    let currentDate = calendar.date(from: DateComponents(year: 2025, month: 6, day: 15))!

    let env = Environment(calendar: calendar, date: currentDate)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.lifetimeProgress(birthdate: birthdate, expectedLifespan: 100)
    #expect(progress == 0.5)
  }

  @Test("lifetime progress can exceed 100% if older than expected lifespan")
  func lifetimeProgressOverflow() {
    let calendar = Calendar(identifier: .gregorian)
    let birthdate = calendar.date(from: DateComponents(year: 1920, month: 1, day: 1))!
    let currentDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!

    let env = Environment(calendar: calendar, date: currentDate)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.lifetimeProgress(birthdate: birthdate, expectedLifespan: 100)
    #expect(progress > 1.0) // 105 years old
  }

  @Test("lifetime progress with custom lifespan")
  func lifetimeProgressCustomLifespan() {
    let calendar = Calendar(identifier: .gregorian)
    let birthdate = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
    let currentDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!

    let env = Environment(calendar: calendar, date: currentDate)
    let calc = ProgressCalculator(environment: env)
    let progress = calc.lifetimeProgress(birthdate: birthdate, expectedLifespan: 50)
    #expect(progress == 0.5) // 25 years old, 50 year lifespan
  }

  // MARK: - Custom Progress

  @Test("custom progress basic calculation")
  func customProgressBasic() {
    let progress = ProgressCalculator.customProgress(start: 0, current: 50, end: 100)
    #expect(progress == 0.5)
  }

  @Test("custom progress at start")
  func customProgressAtStart() {
    let progress = ProgressCalculator.customProgress(start: 10, current: 10, end: 100)
    #expect(progress == 0.0)
  }

  @Test("custom progress at end")
  func customProgressAtEnd() {
    let progress = ProgressCalculator.customProgress(start: 0, current: 100, end: 100)
    #expect(progress == 1.0)
  }

  @Test("custom progress can exceed 100%")
  func customProgressOverflow() {
    let progress = ProgressCalculator.customProgress(start: 0, current: 150, end: 100)
    #expect(progress == 1.5)
  }

  @Test("custom progress negative is clamped to 0")
  func customProgressUnderflow() {
    let progress = ProgressCalculator.customProgress(start: 50, current: 25, end: 100)
    #expect(progress == 0.0) // current < start, should clamp to 0
  }

  // MARK: - Helpers

  private func makeEnvironment(hour: Int, minute: Int, second: Int) -> Environment {
    let calendar = Calendar(identifier: .gregorian)
    let components = DateComponents(
      year: 2025, month: 12, day: 18,
      hour: hour, minute: minute, second: second
    )
    let date = calendar.date(from: components)!
    return Environment(calendar: calendar, date: date)
  }
}
