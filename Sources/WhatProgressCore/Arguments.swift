public struct Arguments: Sendable {
  public var preset: PresetKey?

  // Custom Range

  public var start: Double?
  public var current: Double?
  public var end: Double?

  // Lifetime Options

  public var birthdate: String?
  public var expectedLifespan: Int = 100

  // Display Options

  public var title: String?
  public var titlePosition: TitlePosition
  public var style: StyleKey

  public init(
    preset: PresetKey? = nil,
    start: Double? = nil,
    current: Double? = nil,
    end: Double? = nil,
    birthdate: String? = nil,
    expectedLifespan: Int = 100,
    title: String? = nil,
    titlePosition: TitlePosition = .left,
    style: StyleKey = .modern
  ) {
    self.preset = preset
    self.start = start
    self.current = current
    self.end = end
    self.birthdate = birthdate
    self.expectedLifespan = expectedLifespan
    self.title = title
    self.titlePosition = titlePosition
    self.style = style
  }

  public func parseToOutput(environment: Environment) throws(WhatProgressError) -> String {
    let parsed = try ParsedArguments.parse(self, environment: environment)
    return try parsed.render(environment: environment)
  }
}

public enum PresetKey: String, CaseIterable, Sendable {
  case day
  case week
  case month
  case year
  case life
}

public enum StyleKey: String, CaseIterable, Sendable {
  case modern
  case ascii
}
