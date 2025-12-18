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

  // MARK: - Display Options

  @Option(name: .shortAndLong, help: "Title to display with the progress bar")
  var title: String?

  @Option(name: .long, help: "Position of title relative to bar")
  var titlePosition: TitlePosition = .left

  @Option(name: .long, help: "Bar style")
  var style: StyleKey = .modern
  
  // MARK: - Methods

  mutating func validate() throws {
    lazy var hasCustomValues = start != nil || current != nil || end != nil
    let hasAnyArguments = preset != nil || hasCustomValues
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
  }

  mutating func run() throws {
    print(
      try Arguments(
        preset: preset,
        start: start,
        current: current,
        end: end,
        birthdate: birthdate,
        expectedLifespan: expectedLifespan,
        title: title,
        titlePosition: titlePosition,
        style: style
      )
      .parseToOutput(environment: .current)
    )
  }
}

extension TitlePosition: ExpressibleByArgument {}
extension PresetKey: ExpressibleByArgument {}
extension StyleKey: ExpressibleByArgument {}
