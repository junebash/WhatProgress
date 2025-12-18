import Foundation
import Testing

@testable import WhatProgressCore

@Suite("Arguments Parsing")
struct ArgumentsParsingTests {

  // MARK: - Conflicting Modes

  @Test("throws conflictingModes when preset and custom values both provided")
  func conflictingModesError() {
    let args = Arguments(preset: .day, start: 0, current: 50, end: 100)
    do {
      _ = try args.parseToOutput(environment: makeEnvironment())
      Issue.record("Expected conflictingModes error")
    } catch {
      guard case .conflictingModes = error else {
        Issue.record("Expected conflictingModes but got \(error)")
        return
      }
    }
  }

  // MARK: - Missing Arguments

  @Test("throws missingArguments when no preset or custom values")
  func missingArgumentsError() {
    let args = Arguments()
    do {
      _ = try args.parseToOutput(environment: makeEnvironment())
      Issue.record("Expected missingArguments error")
    } catch {
      guard case .missingArguments = error else {
        Issue.record("Expected missingArguments but got \(error)")
        return
      }
    }
  }

  @Test("throws missingArguments when only partial custom values provided")
  func partialCustomValuesError() {
    let args = Arguments(start: 0, current: 50) // missing end
    do {
      _ = try args.parseToOutput(environment: makeEnvironment())
      Issue.record("Expected missingArguments error")
    } catch {
      guard case .missingArguments = error else {
        Issue.record("Expected missingArguments but got \(error)")
        return
      }
    }
  }

  // MARK: - Birthdate Validation

  @Test("throws missingBirthdate when life preset without birthdate")
  func missingBirthdateError() {
    let args = Arguments(preset: .life)
    do {
      _ = try args.parseToOutput(environment: makeEnvironment())
      Issue.record("Expected missingBirthdate error")
    } catch {
      guard case .missingBirthdate = error else {
        Issue.record("Expected missingBirthdate but got \(error)")
        return
      }
    }
  }

  @Test("throws invalidBirthdateFormat for malformed date")
  func invalidBirthdateFormatError() {
    let args = Arguments(preset: .life, birthdate: "not-a-date")
    do {
      _ = try args.parseToOutput(environment: makeEnvironment())
      Issue.record("Expected invalidBirthdateFormat error")
    } catch {
      guard case .invalidBirthdateFormat = error else {
        Issue.record("Expected invalidBirthdateFormat but got \(error)")
        return
      }
    }
  }

  @Test("throws birthdateInFuture for future date")
  func birthdateInFutureError() {
    // Create environment in the past so the birthdate is in the future
    let pastEnv = makeEnvironment(year: 2020, month: 1, day: 1)
    let args = Arguments(preset: .life, birthdate: "2025-01-01")
    do {
      _ = try args.parseToOutput(environment: pastEnv)
      Issue.record("Expected birthdateInFuture error")
    } catch {
      guard case .birthdateInFuture = error else {
        Issue.record("Expected birthdateInFuture but got \(error)")
        return
      }
    }
  }

  // MARK: - Invalid Range

  @Test("throws invalidRange when start >= end")
  func invalidRangeError() {
    let args = Arguments(start: 100, current: 50, end: 50)
    do {
      _ = try args.parseToOutput(environment: makeEnvironment())
      Issue.record("Expected invalidRange error")
    } catch {
      guard case .invalidRange = error else {
        Issue.record("Expected invalidRange but got \(error)")
        return
      }
    }
  }

  // MARK: - Successful Parsing

  @Test("parses day preset at noon to 50%")
  func parseDayPreset() throws {
    let args = Arguments(preset: .day)
    let output = try args.parseToOutput(environment: makeEnvironment())
    #expect(output == "[██████████░░░░░░░░░░] 50.0%")
  }

  @Test("parses custom range 0-50-100 to 50%")
  func parseCustomRange() throws {
    let args = Arguments(start: 0, current: 50, end: 100)
    let output = try args.parseToOutput(environment: makeEnvironment())
    #expect(output == "[██████████░░░░░░░░░░] 50.0%")
  }

  @Test("parses life preset with birthdate exactly 35 years ago")
  func parseLifePreset() throws {
    // Birthdate exactly 35 years before environment date = 35% of 100 year lifespan
    let args = Arguments(preset: .life, birthdate: "1990-12-18")
    let output = try args.parseToOutput(environment: makeEnvironment())
    #expect(output == "[███████░░░░░░░░░░░░░] 35.0%")
  }

  @Test("includes title to the left by default")
  func includesTitleInOutput() throws {
    let args = Arguments(preset: .day, title: "Progress")
    let output = try args.parseToOutput(environment: makeEnvironment())
    #expect(output == "Progress [██████████░░░░░░░░░░] 50.0%")
  }

  @Test("renders ascii style when specified")
  func asciiStyle() throws {
    let args = Arguments(preset: .day, style: .ascii)
    let output = try args.parseToOutput(environment: makeEnvironment())
    #expect(output == "[##########----------] 50.0%")
  }

  @Test("renders title above when position is above")
  func titleAbove() throws {
    let args = Arguments(preset: .day, title: "Day", titlePosition: .above)
    let output = try args.parseToOutput(environment: makeEnvironment())
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
