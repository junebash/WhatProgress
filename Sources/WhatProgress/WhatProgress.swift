import ArgumentParser
import Foundation

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

  @Option(name: .shortAndLong, help: "Preset time period")
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

  @Option(name: .long, help: "Expected lifespan in years")
  var expectedLifespan: Int = 100

  // MARK: - Date Override

  @Option(name: .long, help: "Override current date (YYYY-MM-DD format)")
  var date: String?

  // MARK: - Display Options

  @Option(name: .shortAndLong, help: "Title to display with the progress bar")
  var title: String?

  @Option(name: .long, help: "Position of title relative to bar")
  var titlePosition: TitlePosition = .left

  @Option(name: .long, help: "Bar style")
  var style: StyleKey = .modern
  
  @Option(name: .shortAndLong, help: "Bar width")
  var width: Int = 20

  // MARK: - Grid Options

  @Option(name: .long, help: "Symbol for filled/past days (grid style, single character)")
  var filledSymbol: String?

  @Option(name: .long, help: "Symbol for empty/future days (grid style, single character)")
  var emptySymbol: String?

  @Option(name: .long, help: "Symbol for today (grid style, single character)")
  var todaySymbol: String?

  @Flag(name: .long, help: "Show month labels (grid style)")
  var showMonthLabels: Bool = false

  @Option(name: .long, help: "View a specific year (grid style)")
  var year: Int?

  var hasCustomValues: Bool {
    start != nil || current != nil || end != nil
  }
  var hasAnyArguments: Bool {
    preset != nil || hasCustomValues
  }
  
  // MARK: - Methods

  mutating func validate() throws {
    guard hasAnyArguments else { throw CleanExit.helpRequest(self) }

    // Check for conflicting modes
    if preset != nil && hasCustomValues {
      throw ValidationError(
        "Cannot specify both --preset and custom range options (--start, --current, --end)."
      )
    }

    // Check for partial custom values
    if hasCustomValues && !(start != nil && current != nil && end != nil) {
      throw ValidationError(
        "Custom range requires all three options: --start, --current, and --end."
      )
    }

    // Check for missing birthdate with life preset
    if preset == .life && birthdate == nil {
      throw ValidationError("The 'life' preset requires --birthdate.")
    }

    // Check for invalid range
    if let s = start, let e = end, s >= e {
      throw ValidationError("--start must be less than --end.")
    }

    // Check for grid style requiring year preset
    if style == .grid && preset != .year {
      throw ValidationError("The 'grid' style requires the 'year' preset (-p year).")
    }
  }
  
  mutating func run() throws {
    let env = try environmentWithDateOverride(.current)
    env.print(try render(environment: env))
  }

  func environmentWithDateOverride(_ base: Environment) throws -> Environment {
    guard let dateString = date else { return base }
    let parser = Date.VerbatimFormatStyle(
      format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
      locale: base.locale,
      timeZone: base.timeZone,
      calendar: base.calendar
    ).parseStrategy
    let parsedDate: Date
    do {
      parsedDate = try parser.parse(dateString)
    } catch {
      throw WhatProgressError.invalidDateFormat(description: error.localizedDescription)
    }
    var modified = base
    modified.date = parsedDate
    return modified
  }

  func render(environment: Environment) throws -> String {
    try ParsedArguments(
      progress: progress(environment: environment),
      title: title.map { ParsedArguments.TitleOptions(title: $0, position: titlePosition) },
      renderStyle: makeRenderStyle()
    )
    .render(environment: environment)
  }

  func makeRenderStyle() -> ParsedArguments.RenderStyle {
    switch style {
    case .modern:
      return .progressBar(.barFill(.modern(width: width)))
    case .ascii:
      return .progressBar(.barFill(.ascii(width: width)))
    case .grid:
      let config = YearGrid.Configuration(
        filledSymbol: filledSymbol?.first ?? "█",
        emptySymbol: emptySymbol?.first ?? "░",
        todaySymbol: todaySymbol?.first,
        showMonthLabels: showMonthLabels
      )
      return .yearGrid(ParsedArguments.YearGridOptions(year: year, configuration: config))
    }
  }
  
  func progress(environment: Environment) throws -> ParsedArguments.Progress {
    if let preset {
      return try ParsedArguments.parsePreset(
        preset,
        birthdateString: birthdate,
        expectedLifespan: expectedLifespan,
        environment: environment
      )
    } else if hasCustomValues {
      let (start, current, end) = try zip(start, current, end).orThrow(
        ValidationError(
          "Custom range requires all three options: --start, --current, and --end."
        )
      )
      if start >= end { throw WhatProgressError.invalidRange }
      return .customRange(
        ParsedArguments.Progress.CustomRange(start: start, current: current, end: end)
      )
    } else {
      throw ValidationError(
        "Must specify either --preset or custom range options (--start, --current, --end)."
      )
    }
  }
}

enum PresetKey: String, CaseIterable, Sendable {
  case day
  case week
  case month
  case year
  case life
}

enum StyleKey: String, CaseIterable, Sendable {
  case modern
  case ascii
  case grid
}

extension TitlePosition: ExpressibleByArgument {}
extension PresetKey: ExpressibleByArgument {}
extension StyleKey: ExpressibleByArgument {}
