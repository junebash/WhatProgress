import Foundation
import Testing

@testable import WhatProgress

@Suite("ParsedArguments Integration")
struct ParsedArgumentsIntegrationTests {

  // MARK: - Error Cases

  @Test("throws missingBirthdate when life preset without birthdate")
  func missingBirthdateError() {
    #expect(throws: WhatProgressError.missingBirthdate) {
      _ = try ParsedArguments.parsePreset(
        .life,
        birthdateString: nil,
        expectedLifespan: 100,
        environment: makeEnvironment()
      )
    }
  }

  @Test("throws invalidBirthdateFormat for malformed date")
  func invalidBirthdateFormatError() throws {
    let error = try #require(throws: WhatProgressError.self) {
      _ = try ParsedArguments.parsePreset(
        .life,
        birthdateString: "not-a-date",
        expectedLifespan: 100,
        environment: makeEnvironment()
      )
    }
    #expect(error.is(\.invalidBirthdateFormat), "Expected invalidBirthdateFormat error, got \(error)")
  }

  @Test("throws birthdateInFuture for future date")
  func birthdateInFutureError() {
    // Create environment in the past so the birthdate is in the future
    let pastEnv = makeEnvironment(year: 2020, month: 1, day: 1)
    #expect(throws: WhatProgressError.birthdateInFuture) {
      _ = try ParsedArguments.parsePreset(
        .life,
        birthdateString: "2025-01-01",
        expectedLifespan: 100,
        environment: pastEnv
      )
    }
  }

  @Test("throws invalidRange when start >= end")
  func invalidRangeError() {
    let range = ParsedArguments.Progress.CustomRange(start: 100, current: 50, end: 50)
    let parsed = ParsedArguments(
      progress: .customRange(range),
      title: nil,
      renderStyle: .progressBar(.barFill(.modern()))
    )
    #expect(throws: WhatProgressError.invalidRange) {
      _ = try parsed.render(environment: makeEnvironment())
    }
  }

  // MARK: - Successful Parsing

  @Test("parses day preset at noon to 50%")
  func parseDayPreset() throws {
    let progress = try ParsedArguments.parsePreset(
      .day,
      birthdateString: nil,
      expectedLifespan: 100,
      environment: makeEnvironment()
    )
    let parsed = ParsedArguments(
      progress: progress,
      title: nil,
      renderStyle: .progressBar(.barFill(.modern()))
    )
    let output = try parsed.render(environment: makeEnvironment())
    #expect(output == "[██████████░░░░░░░░░░] 50.0%")
  }

  @Test("parses custom range 0-50-100 to 50%")
  func parseCustomRange() throws {
    let range = ParsedArguments.Progress.CustomRange(start: 0, current: 50, end: 100)
    let parsed = ParsedArguments(
      progress: .customRange(range),
      title: nil,
      renderStyle: .progressBar(.barFill(.modern()))
    )
    let output = try parsed.render(environment: makeEnvironment())
    #expect(output == "[██████████░░░░░░░░░░] 50.0%")
  }

  @Test("parses life preset with birthdate exactly 35 years ago")
  func parseLifePreset() throws {
    // Birthdate exactly 35 years before environment date = 35% of 100 year lifespan
    let progress = try ParsedArguments.parsePreset(
      .life,
      birthdateString: "1990-12-18",
      expectedLifespan: 100,
      environment: makeEnvironment()
    )
    let parsed = ParsedArguments(
      progress: progress,
      title: nil,
      renderStyle: .progressBar(.barFill(.modern()))
    )
    let output = try parsed.render(environment: makeEnvironment())
    #expect(output == "[███████░░░░░░░░░░░░░] 35.0%")
  }

  @Test("includes title to the left by default")
  func includesTitleInOutput() throws {
    let progress = try ParsedArguments.parsePreset(
      .day,
      birthdateString: nil,
      expectedLifespan: 100,
      environment: makeEnvironment()
    )
    let titleOptions = ParsedArguments.TitleOptions(title: "Progress", position: .left)
    let parsed = ParsedArguments(
      progress: progress,
      title: titleOptions,
      renderStyle: .progressBar(.barFill(.modern()))
    )
    let output = try parsed.render(environment: makeEnvironment())
    #expect(output == "Progress [██████████░░░░░░░░░░] 50.0%")
  }

  @Test("renders ascii style when specified")
  func asciiStyle() throws {
    let progress = try ParsedArguments.parsePreset(
      .day,
      birthdateString: nil,
      expectedLifespan: 100,
      environment: makeEnvironment()
    )
    let parsed = ParsedArguments(
      progress: progress,
      title: nil,
      renderStyle: .progressBar(.barFill(.ascii()))
    )
    let output = try parsed.render(environment: makeEnvironment())
    #expect(output == "[##########..........] 50.0%")
  }

  @Test("renders title above when position is above")
  func titleAbove() throws {
    let progress = try ParsedArguments.parsePreset(
      .day,
      birthdateString: nil,
      expectedLifespan: 100,
      environment: makeEnvironment()
    )
    let titleOptions = ParsedArguments.TitleOptions(title: "Day", position: .above)
    let parsed = ParsedArguments(
      progress: progress,
      title: titleOptions,
      renderStyle: .progressBar(.barFill(.modern()))
    )
    let output = try parsed.render(environment: makeEnvironment())
    #expect(output == "Day\n[██████████░░░░░░░░░░] 50.0%")
  }

  // MARK: - Helpers

  private static let testTimeZone = TimeZone(identifier: "America/Los_Angeles")!

  private func makeEnvironment(
    year: Int = 2025,
    month: Int = 12,
    day: Int = 18
  ) -> Environment {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = Self.testTimeZone
    calendar.locale = Locale(identifier: "en_US")
    calendar.firstWeekday = 1

    var components = DateComponents(
      year: year, month: month, day: day,
      hour: 12, minute: 0, second: 0
    )
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!

    return Environment(calendar: calendar, timeZone: Self.testTimeZone, date: date)
  }
}
