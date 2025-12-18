import Foundation

struct ParsedArguments: Sendable, Equatable {
  enum Progress: Sendable, Equatable {
    struct CustomRange: Sendable, Equatable {
      var start, current, end: Double
    }

    struct LifetimeOptions: Sendable, Equatable {
      var birthdate: Date
      var expectedLifespan: Int
    }

    enum Preset: Equatable, Sendable {
      case day, week, month, year
      case life(LifetimeOptions)
    }

    case preset(Preset)
    case customRange(CustomRange)
  }

  struct TitleOptions: Sendable, Equatable {
    var title: String
    var position: TitlePosition
  }

  var progress: Progress
  var title: TitleOptions?
  var style: ProgressBar.Style

  static func parse(
    _ arguments: Arguments,
    environment: Environment
  ) throws(WhatProgressError) -> ParsedArguments {
    let hasCustomValues = arguments.start != nil || arguments.current != nil || arguments.end != nil
    if arguments.preset != nil && hasCustomValues { throw .conflictingModes }

    let progress: Progress
    if let preset = arguments.preset {
      progress = try parsePreset(
        preset,
        birthdateString: arguments.birthdate,
        expectedLifespan: arguments.expectedLifespan,
        environment: environment
      )
    } else if hasCustomValues {
      progress = try parseCustomRange(arguments)
    } else {
      throw .missingArguments
    }

    let titleOptions: TitleOptions? = arguments.title.map {
      TitleOptions(title: $0, position: arguments.titlePosition)
    }

    let style: ProgressBar.Style = switch arguments.style {
    case .modern: .barFill(.modern())
    case .ascii: .barFill(.ascii())
    }

    return ParsedArguments(progress: progress, title: titleOptions, style: style)
  }

  func render(environment: Environment) throws(WhatProgressError) -> String {
    ProgressBar(
      progress: try ProgressCalculator(environment: environment).calculate(progress),
      title: title?.title,
      titlePosition: title?.position ?? .left,
      style: style
    ).render()
  }

  static func parsePreset(
    _ preset: PresetKey,
    birthdateString: String?,
    expectedLifespan: Int,
    environment: Environment
  ) throws(WhatProgressError) -> Progress {
    switch preset {
    case .day:
      return .preset(.day)
    case .week:
      return .preset(.week)
    case .month:
      return .preset(.month)
    case .year:
      return .preset(.year)
    case .life:
      guard let birthdateString else { throw .missingBirthdate }
      let parser = Date.VerbatimFormatStyle(
        format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
        locale: environment.locale,
        timeZone: environment.timeZone,
        calendar: environment.calendar
      ).parseStrategy
      let birthdate: Date
      do {
        birthdate = try parser.parse(birthdateString)
      } catch {
        throw .invalidBirthdateFormat(error)
      }
      if birthdate > environment.date { throw .birthdateInFuture }
      let options = Progress.LifetimeOptions(
        birthdate: birthdate,
        expectedLifespan: expectedLifespan
      )
      return .preset(.life(options))
    }
  }

  static func parseCustomRange(
    _ arguments: Arguments
  ) throws(WhatProgressError) -> Progress {
    guard
      let start = arguments.start,
      let current = arguments.current,
      let end = arguments.end
    else { throw .missingArguments }

    if start >= end {
      throw .invalidRange
    }

    return .customRange(Progress.CustomRange(start: start, current: current, end: end))
  }
}
