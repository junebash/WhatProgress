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
  var titlePosition: TitlePosition = .left

  @Option(name: .long, help: "Bar style: modern or ascii (default: modern)")
  var style: StyleKey = .modern
  
  // MARK: - Methods

  mutating func run() throws {
    let hasAnyArguments = preset != nil || start != nil || current != nil || end != nil
    guard hasAnyArguments else { throw CleanExit.helpRequest(self) }

    let arguments = Arguments(
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

    let output = try arguments.parseToOutput(environment: .current)
    print(output)
  }
}

extension TitlePosition: ExpressibleByArgument {}
extension PresetKey: ExpressibleByArgument {}
extension StyleKey: ExpressibleByArgument {}
