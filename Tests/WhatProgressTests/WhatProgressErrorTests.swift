import Foundation
import Testing

@testable import WhatProgress

@Suite("WhatProgressError Descriptions")
struct WhatProgressErrorTests {

  @Test("missingBirthdate error description from parsePreset")
  func missingBirthdateDescription() throws {
    let error = try #require(throws: WhatProgressError.self) {
      try ParsedArguments.parsePreset(
        .life,
        birthdateString: nil,
        expectedLifespan: 100,
        environment: makeEnvironment()
      )
    }
    #expect(error.description == "Lifetime progress requires --birthdate parameter.")
  }

  @Test("invalidBirthdateFormat error description from parsePreset")
  func invalidBirthdateFormatDescription() throws {
    let error = try #require(throws: WhatProgressError.self) {
      try ParsedArguments.parsePreset(
        .life,
        birthdateString: "not-a-date",
        expectedLifespan: 100,
        environment: makeEnvironment()
      )
    }
    #expect(error.description == "Birthdate must be in YYYY-MM-DD format.")
  }

  @Test("birthdateInFuture error description from parsePreset")
  func birthdateInFutureDescription() throws {
    let error = try #require(throws: WhatProgressError.self) {
      try ParsedArguments.parsePreset(
        .life,
        birthdateString: "2030-01-01",
        expectedLifespan: 100,
        environment: makeEnvironment()
      )
    }
    #expect(error.description == "Birthdate cannot be in the future.")
  }

  @Test("invalidRange error description from customProgress")
  func invalidRangeDescriptionFromCustomProgress() throws {
    let calc = ProgressCalculator(environment: makeEnvironment())
    let range = ParsedArguments.Progress.CustomRange(start: 100, current: 50, end: 50)
    let error = try #require(throws: WhatProgressError.self) {
      try calc.calculate(.customRange(range))
    }
    #expect(error.description == "Start value must be less than end value.")
  }

  // MARK: - Helpers

  private static let testTimeZone = TimeZone(identifier: "America/Los_Angeles")!

  private func makeEnvironment() -> Environment {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = Self.testTimeZone
    calendar.locale = Locale(identifier: "en_US")
    calendar.firstWeekday = 1

    var components = DateComponents(
      year: 2025, month: 12, day: 18,
      hour: 12, minute: 0, second: 0
    )
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!

    return Environment(calendar: calendar, timeZone: Self.testTimeZone, date: date)
  }
}
