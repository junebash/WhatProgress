import ArgumentParser
import Foundation
import WhatProgressCore

@main
struct WhatProgress: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Display progress through time periods as a visual progress bar.",
    discussion: """
      Show progress through day, week, month, year, or lifetime.
      Alternatively, calculate progress through a custom range.

      Examples:
        whatprogress -p year
        whatprogress -p life -b 1990-01-15
        whatprogress -s 0 -c 75 -e 100 -t "Download"
      """
  )

  // MARK: - Mode Selection

  @Option(name: .shortAndLong, help: "Preset time period (day, week, month, year, life)")
  var preset: PresetKey?

  // MARK: - Custom Range

  @Option(name: .shortAndLong, help: "Start value for custom range")
  var start: Double?

  @Option(name: .shortAndLong, help: "Current value for custom range")
  var current: Double?

  @Option(name: .shortAndLong, help: "End value for custom range")
  var end: Double?

  // MARK: - Lifetime Options

  @Option(name: .shortAndLong, help: "Birthdate for lifetime progress (YYYY-MM-DD)")
  var birthdate: String?

  @Option(name: .long, help: "Expected lifespan in years (default: 100)")
  var expectedLifespan: Int = 100

  // MARK: - Display Options

  @Option(name: .shortAndLong, help: "Title to display with the progress bar")
  var title: String?

  @Option(name: .long, help: "Position of title: above or left (default: left)")
  var titlePosition: TitlePositionArg = .left

  @Flag(name: .long, help: "Use ASCII characters instead of Unicode")
  var ascii: Bool = false

  mutating func run() throws {
    let hasCustomValues = start != nil || current != nil || end != nil

    // Check for conflicting modes
    if preset != nil && hasCustomValues {
      throw Failure.conflictingModes
    }

    // Calculate progress based on mode
    let progress: Double

    if let preset {
      progress = try calculatePresetProgress(preset)
    } else if hasCustomValues {
      progress = try calculateCustomProgress()
    } else {
      // No mode specified - show help
      throw CleanExit.helpRequest(self)
    }

    // Convert title position
    let position: TitlePosition = titlePosition == .above ? .above : .left

    // Render and print progress bar
    let bar = ProgressBar(
      progress: progress,
      title: title,
      titlePosition: position,
      useAscii: ascii
    )
    print(bar.render())
  }

  private func calculatePresetProgress(_ preset: PresetKey) throws -> Double {
    let calculator = ProgressCalculator()

    switch preset {
    case .day:
      return calculator.dayProgress()
    case .week:
      return calculator.weekProgress()
    case .month:
      return calculator.monthProgress()
    case .year:
      return calculator.yearProgress()
    case .life:
      return try calculateLifetimeProgress(calculator: calculator)
    }
  }

  private func calculateLifetimeProgress(calculator: ProgressCalculator) throws -> Double {
    guard let birthdateString = birthdate else {
      throw Failure.missingBirthdate
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone.current

    guard let birthdateDate = formatter.date(from: birthdateString) else {
      throw Failure.invalidBirthdateFormat
    }

    if birthdateDate > Date.now {
      throw Failure.birthdateInFuture
    }

    return calculator.lifetimeProgress(birthdate: birthdateDate, expectedLifespan: expectedLifespan)
  }

  private func calculateCustomProgress() throws -> Double {
    guard let startVal = start, let currentVal = current, let endVal = end else {
      throw Failure.missingArguments
    }

    if startVal >= endVal {
      throw Failure.invalidRange
    }

    return ProgressCalculator.customProgress(start: startVal, current: currentVal, end: endVal)
  }
}

// MARK: - Supporting Types

enum PresetKey: String, ExpressibleByArgument, CaseIterable {
  case day
  case week
  case month
  case year
  case life
}

enum TitlePositionArg: String, ExpressibleByArgument {
  case above
  case left
}

extension WhatProgress {
  enum Failure: Error, CustomStringConvertible {
    case missingArguments
    case missingBirthdate
    case invalidBirthdateFormat
    case birthdateInFuture
    case invalidRange
    case conflictingModes

    var description: String {
      switch self {
      case .missingArguments:
        return "Custom mode requires --start, --current, and --end values."
      case .missingBirthdate:
        return "Lifetime progress requires --birthdate parameter."
      case .invalidBirthdateFormat:
        return "Birthdate must be in YYYY-MM-DD format."
      case .birthdateInFuture:
        return "Birthdate cannot be in the future."
      case .invalidRange:
        return "Start value must be less than end value."
      case .conflictingModes:
        return "Cannot specify both preset and custom values. Choose one mode."
      }
    }
  }
}
