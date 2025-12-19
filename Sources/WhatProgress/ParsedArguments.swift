import CasePaths
import Foundation

struct ParsedArguments: Sendable, Equatable {
  @CasePathable
  @dynamicMemberLookup
  enum Progress: Sendable, Equatable {
    case preset(Preset)
    case customRange(CustomRange)
    
    struct CustomRange: Sendable, Equatable {
      var start, current, end: Double
    }

    struct LifetimeOptions: Sendable, Equatable {
      var birthdate: Date
      var expectedLifespan: Int
    }

    @CasePathable
    @dynamicMemberLookup
    enum Preset: Equatable, Sendable {
      case day, week, month, year
      case life(LifetimeOptions)
    }
  }

  struct TitleOptions: Sendable, Equatable {
    var title: String
    var position: TitlePosition
  }

  var progress: Progress
  var title: TitleOptions?
  var style: ProgressBar.Style

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
        throw .invalidBirthdateFormat(description: error.localizedDescription)
      }
      if birthdate > environment.date { throw .birthdateInFuture }
      let options = Progress.LifetimeOptions(
        birthdate: birthdate,
        expectedLifespan: expectedLifespan
      )
      return .preset(.life(options))
    }
  }
}
