import ArgumentParser
import CasePaths
import Foundation
import Testing
@testable import WhatProgress

@Suite("CLI End-to-End Tests")
struct CLITests {

  // MARK: - Custom Range Tests (Deterministic)

  @Test("Custom range 0-50-100 produces exactly 50.0%")
  func customRange50Percent() throws {
    let output = try runCLI(args: ["-s", "0", "-c", "50", "-e", "100"])
    #expect(output == "[██████████░░░░░░░░░░] 50.0%")
  }

  @Test("Custom range 0-0-100 produces exactly 0.0%")
  func customRange0Percent() throws {
    let output = try runCLI(args: ["-s", "0", "-c", "0", "-e", "100"])
    #expect(output == "[░░░░░░░░░░░░░░░░░░░░] 0.0%")
  }

  @Test("Custom range 0-100-100 produces exactly 100.0%")
  func customRange100Percent() throws {
    let output = try runCLI(args: ["-s", "0", "-c", "100", "-e", "100"])
    #expect(output == "[████████████████████] 100.0%")
  }

  @Test("Custom range 0-25-100 produces exactly 25.0%")
  func customRange25Percent() throws {
    let output = try runCLI(args: ["-s", "0", "-c", "25", "-e", "100"])
    #expect(output == "[█████░░░░░░░░░░░░░░░] 25.0%")
  }

  @Test("Custom range 0-75-100 produces exactly 75.0%")
  func customRange75Percent() throws {
    let output = try runCLI(args: ["-s", "0", "-c", "75", "-e", "100"])
    #expect(output == "[███████████████░░░░░] 75.0%")
  }

  // MARK: - Title Tests

  @Test("Custom range with title on left")
  func customRangeWithTitleLeft() throws {
    let output = try runCLI(args: ["-s", "0", "-c", "50", "-e", "100", "-t", "Download"])
    #expect(output == "Download [██████████░░░░░░░░░░] 50.0%")
  }

  @Test("Custom range with title above")
  func customRangeWithTitleAbove() throws {
    let output = try runCLI(args: [
      "-s", "0", "-c", "50", "-e", "100",
      "-t", "Progress",
      "--title-position", "above"
    ])
    #expect(output == "Progress\n[██████████░░░░░░░░░░] 50.0%")
  }

  // MARK: - Style Tests

  @Test("ASCII style produces exact ASCII output")
  func asciiStyle() throws {
    let output = try runCLI(args: ["-s", "0", "-c", "50", "-e", "100", "--style", "ascii"])
    #expect(output == "[##########----------] 50.0%")
  }

  @Test("ASCII style with 0%")
  func asciiStyle0Percent() throws {
    let output = try runCLI(args: ["-s", "0", "-c", "0", "-e", "100", "--style", "ascii"])
    #expect(output == "[--------------------] 0.0%")
  }

  @Test("ASCII style with 100%")
  func asciiStyle100Percent() throws {
    let output = try runCLI(args: ["-s", "0", "-c", "100", "-e", "100", "--style", "ascii"])
    #expect(output == "[####################] 100.0%")
  }

  // MARK: - Error Tests

  @Test("Invalid range start >= end produces exact error")
  func invalidRangeError() throws {
    let error = try #require(throws: (any Error).self) {
      try runCLI(args: ["-s", "100", "-c", "50", "-e", "100"])
    }
    #expect(String(describing: error).contains("--start must be less than --end"))
  }

  @Test("Conflicting modes produces exact error")
  func conflictingModesError() throws {
    let error = try #require(throws: (any Error).self) {
      try runCLI(args: ["-p", "day", "-s", "0", "-c", "50", "-e", "100"])
    }
    #expect(String(describing: error).contains("Cannot specify both --preset and custom range options"))
  }

  @Test("Missing birthdate for life preset produces exact error")
  func missingBirthdateError() throws {
    let error = try #require(throws: (any Error).self) {
      try runCLI(args: ["-p", "life"])
    }
    #expect(String(describing: error).contains("'life' preset requires --birthdate"))
  }

  @Test("Invalid birthdate format produces exact error")
  func invalidBirthdateFormatError() throws {
    let error = try #require(throws: WhatProgressError.self) {
      try runCLI(args: ["-p", "life", "-b", "not-a-date"])
    }
    #expect(error.is(\.invalidBirthdateFormat))
  }

  @Test("Future birthdate produces exact error")
  func futureBirthdateError() throws {
    try #require(throws: WhatProgressError.birthdateInFuture) {
      try runCLI(args: ["-p", "life", "-b", "2099-01-01"])
    }
  }

  @Test("Partial custom range missing end produces exact error")
  func partialCustomRangeMissingEnd() throws {
    let error = try #require(throws: (any Error).self) {
      try runCLI(args: ["-s", "0", "-c", "50"])
    }
    #expect(String(describing: error).contains("Custom range requires all three options"))
  }

  @Test("Partial custom range missing start produces exact error")
  func partialCustomRangeMissingStart() throws {
    let error = try #require(throws: (any Error).self) {
      try runCLI(args: ["-c", "50", "-e", "100"])
    }
    #expect(String(describing: error).contains("Custom range requires all three options"))
  }

  // MARK: - Preset Tests (Verify exact structure with regex validation)

  @Test("Day preset produces valid progress with exact format")
  func dayPresetFormat() throws {
    let output = try runCLI(args: ["-p", "day"])

    // Must match exact format: [<20 chars>] <percentage>%
    let pattern = /^\[[\u{2588}\u{2591}]{20}\] \d+\.\d+%$/
    #expect(output.wholeMatch(of: pattern) != nil)
  }

  @Test("Week preset produces valid progress with exact format")
  func weekPresetFormat() throws {
    let output = try runCLI(args: ["-p", "week"])

    let pattern = /^\[[\u{2588}\u{2591}]{20}\] \d+\.\d+%$/
    #expect(output.wholeMatch(of: pattern) != nil)
  }

  @Test("Month preset produces valid progress with exact format")
  func monthPresetFormat() throws {
    let output = try runCLI(args: ["-p", "month"])

    let pattern = /^\[[\u{2588}\u{2591}]{20}\] \d+\.\d+%$/
    #expect(output.wholeMatch(of: pattern) != nil)
  }

  @Test("Year preset produces valid progress with exact format")
  func yearPresetFormat() throws {
    let output = try runCLI(args: ["-p", "year"])

    let pattern = /^\[[\u{2588}\u{2591}]{20}\] \d+\.\d+%$/
    #expect(output.wholeMatch(of: pattern) != nil)
  }

  @Test("Life preset with valid birthdate produces exact format")
  func lifePresetFormat() throws {
    let output = try runCLI(args: ["-p", "life", "-b", "1990-01-15"])

    // Must match exact format and percentage must be reasonable
    let pattern = /^\[[\u{2588}\u{2591}]{20}\] (\d+\.\d+)%$/
    let match = try #require(output.wholeMatch(of: pattern))
    let percentageStr = String(match.1)
    let percentage = try #require(Double(percentageStr))
    #expect(percentage >= 0.0 && percentage <= 100.0)
  }

  // MARK: - Helper Methods

  private func runCLI(args: [String]) throws -> String {
    var calendar = Calendar(identifier: .gregorian)
    let timeZone = TimeZone.gmt
    let locale = Locale(languageCode: .english, script: .latin, languageRegion: .unitedStates)
    calendar.timeZone = timeZone
    calendar.locale = locale
    
    let command = try #require(WhatProgress.parseAsRoot(args) as? WhatProgress)
    return try command.render(
      environment: Environment(
        calendar: calendar,
        timeZone: timeZone,
        locale: locale,
        date: Date(timeIntervalSinceReferenceDate: 0),
        print: { Issue.record("Unexpected print: \($0)") }
      )
    )
  }
}
