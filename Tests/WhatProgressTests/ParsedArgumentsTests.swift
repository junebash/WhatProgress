import Foundation
import Testing

@testable import WhatProgressCore

@Suite("ParsedArguments.parsePreset")
struct ParsedArgumentsTests {

  // MARK: - Day Preset

  @Test("parsePreset returns day preset")
  func parsePresetDay() throws {
    let result = try ParsedArguments.parsePreset(
      .day,
      birthdateString: nil,
      expectedLifespan: 100,
      environment: makeEnvironment()
    )
    #expect(result == .preset(.day))
  }

  // MARK: - Week Preset

  @Test("parsePreset returns week preset")
  func parsePresetWeek() throws {
    let result = try ParsedArguments.parsePreset(
      .week,
      birthdateString: nil,
      expectedLifespan: 100,
      environment: makeEnvironment()
    )
    #expect(result == .preset(.week))
  }

  // MARK: - Month Preset

  @Test("parsePreset returns month preset")
  func parsePresetMonth() throws {
    let result = try ParsedArguments.parsePreset(
      .month,
      birthdateString: nil,
      expectedLifespan: 100,
      environment: makeEnvironment()
    )
    #expect(result == .preset(.month))
  }

  // MARK: - Year Preset

  @Test("parsePreset returns year preset")
  func parsePresetYear() throws {
    let result = try ParsedArguments.parsePreset(
      .year,
      birthdateString: nil,
      expectedLifespan: 100,
      environment: makeEnvironment()
    )
    #expect(result == .preset(.year))
  }

  // MARK: - Life Preset - Success Cases

  @Test("parsePreset returns life preset with valid birthdate")
  func parsePresetLifeValid() throws {
    let result = try ParsedArguments.parsePreset(
      .life,
      birthdateString: "1990-06-15",
      expectedLifespan: 80,
      environment: makeEnvironment()
    )

    guard case .preset(.life(let options)) = result else {
      Issue.record("Expected .preset(.life) but got \(result)")
      return
    }

    #expect(options.expectedLifespan == 80)

    // Verify the parsed birthdate
    let calendar = makeTestCalendar()
    var expectedComponents = DateComponents(year: 1990, month: 6, day: 15)
    expectedComponents.timeZone = Self.testTimeZone
    let expectedDate = calendar.date(from: expectedComponents)!

    #expect(options.birthdate == expectedDate)
  }

  @Test("parsePreset life preset with default lifespan")
  func parsePresetLifeDefaultLifespan() throws {
    let result = try ParsedArguments.parsePreset(
      .life,
      birthdateString: "2000-01-01",
      expectedLifespan: 100,
      environment: makeEnvironment()
    )

    guard case .preset(.life(let options)) = result else {
      Issue.record("Expected .preset(.life) but got \(result)")
      return
    }

    #expect(options.expectedLifespan == 100)
  }

  // MARK: - Life Preset - Error Cases

  @Test("parsePreset throws missingBirthdate when birthdate is nil")
  func parsePresetLifeMissingBirthdate() {
    do {
      _ = try ParsedArguments.parsePreset(
        .life,
        birthdateString: nil,
        expectedLifespan: 100,
        environment: makeEnvironment()
      )
      Issue.record("Expected missingBirthdate error")
    } catch {
      guard case .missingBirthdate = error else {
        Issue.record("Expected missingBirthdate but got \(error)")
        return
      }
    }
  }

  @Test("parsePreset throws invalidBirthdateFormat for malformed date")
  func parsePresetLifeInvalidFormat() {
    do {
      _ = try ParsedArguments.parsePreset(
        .life,
        birthdateString: "not-a-date",
        expectedLifespan: 100,
        environment: makeEnvironment()
      )
      Issue.record("Expected invalidBirthdateFormat error")
    } catch {
      guard case .invalidBirthdateFormat = error else {
        Issue.record("Expected invalidBirthdateFormat but got \(error)")
        return
      }
    }
  }

  @Test("parsePreset throws invalidBirthdateFormat for wrong format")
  func parsePresetLifeWrongFormat() {
    do {
      _ = try ParsedArguments.parsePreset(
        .life,
        birthdateString: "06/15/1990",
        expectedLifespan: 100,
        environment: makeEnvironment()
      )
      Issue.record("Expected invalidBirthdateFormat error")
    } catch {
      guard case .invalidBirthdateFormat = error else {
        Issue.record("Expected invalidBirthdateFormat but got \(error)")
        return
      }
    }
  }

  @Test("parsePreset throws birthdateInFuture when date is after current date")
  func parsePresetLifeFutureBirthdate() {
    do {
      _ = try ParsedArguments.parsePreset(
        .life,
        birthdateString: "2030-01-01",
        expectedLifespan: 100,
        environment: makeEnvironment()
      )
      Issue.record("Expected birthdateInFuture error")
    } catch {
      guard case .birthdateInFuture = error else {
        Issue.record("Expected birthdateInFuture but got \(error)")
        return
      }
    }
  }

  @Test("parsePreset accepts birthdate equal to current date")
  func parsePresetLifeSameDateAsCurrent() throws {
    let result = try ParsedArguments.parsePreset(
      .life,
      birthdateString: "2025-12-18",
      expectedLifespan: 100,
      environment: makeEnvironment()
    )

    guard case .preset(.life) = result else {
      Issue.record("Expected .preset(.life) but got \(result)")
      return
    }
  }

  // MARK: - Helpers

  private static let testTimeZone = TimeZone(identifier: "America/Los_Angeles")!

  private func makeTestCalendar() -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = Self.testTimeZone
    calendar.locale = Locale(identifier: "en_US")
    calendar.firstWeekday = 1
    return calendar
  }

  private func makeEnvironment() -> Environment {
    let calendar = makeTestCalendar()
    var components = DateComponents(
      year: 2025, month: 12, day: 18,
      hour: 12, minute: 0, second: 0
    )
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!
    return Environment(calendar: calendar, timeZone: Self.testTimeZone, date: date)
  }
}
