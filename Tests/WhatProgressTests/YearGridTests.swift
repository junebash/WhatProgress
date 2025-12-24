import Foundation
import Testing

@testable import WhatProgress

@Suite("Year Grid Rendering")
struct YearGridTests {

  // MARK: - Basic Structure

  @Test("renders 12 rows for 12 months")
  func renders12Rows() {
    let grid = makeGrid(month: 6, day: 15)
    let lines = grid.render().split(separator: "\n")
    #expect(lines.count == 12)
  }

  @Test("January has 31 characters")
  func januaryHas31Characters() {
    let grid = makeGrid(month: 6, day: 15)
    let lines = grid.render().split(separator: "\n")
    #expect(lines[0].count == 31)
  }

  @Test("February in non-leap year has 28 characters")
  func februaryNonLeapYearHas28Characters() {
    let grid = makeGrid(year: 2025, month: 6, day: 15)
    let lines = grid.render().split(separator: "\n")
    #expect(lines[1].count == 28)
  }

  @Test("February in leap year has 29 characters")
  func februaryLeapYearHas29Characters() {
    let grid = makeGrid(year: 2024, month: 6, day: 15)
    let lines = grid.render().split(separator: "\n")
    #expect(lines[1].count == 29)
  }

  @Test("April has 30 characters")
  func aprilHas30Characters() {
    let grid = makeGrid(month: 6, day: 15)
    let lines = grid.render().split(separator: "\n")
    #expect(lines[3].count == 30)
  }

  // MARK: - Progress Rendering

  @Test("January 1st shows only first day filled")
  func january1stShowsFirstDayFilled() {
    let grid = makeGrid(month: 1, day: 1)
    let lines = grid.render().split(separator: "\n")
    let january = String(lines[0])
    #expect(january.hasPrefix("█"))
    #expect(january.dropFirst().allSatisfy { $0 == "░" })
  }

  @Test("December 31st shows all months filled")
  func december31stShowsAllFilled() {
    let grid = makeGrid(month: 12, day: 31)
    let output = grid.render()
    #expect(output.allSatisfy { $0 == "█" || $0 == "\n" })
  }

  @Test("mid-year shows correct filled/empty split")
  func midYearShowsCorrectSplit() {
    let grid = makeGrid(month: 7, day: 4)
    let lines = grid.render().split(separator: "\n")

    // January through June should be fully filled
    for month in 0..<6 {
      let line = String(lines[month])
      #expect(line.allSatisfy { $0 == "█" }, "Month \(month + 1) should be all filled")
    }

    // July should be partially filled (4 days)
    let july = String(lines[6])
    #expect(july.hasPrefix("████"))
    #expect(july.dropFirst(4).allSatisfy { $0 == "░" })

    // August through December should be all empty
    for month in 7..<12 {
      let line = String(lines[month])
      #expect(line.allSatisfy { $0 == "░" }, "Month \(month + 1) should be all empty")
    }
  }

  // MARK: - Today Marker

  @Test("today marker appears on correct day")
  func todayMarkerAppearsOnCorrectDay() {
    var config = YearGrid.Configuration.modern()
    config.todaySymbol = "◆"

    let grid = makeGrid(month: 11, day: 5, configuration: config)
    let lines = grid.render().split(separator: "\n")
    let november = String(lines[10])

    // Day 5 should have the marker (index 4)
    #expect(november[november.index(november.startIndex, offsetBy: 4)] == "◆")
    // Days 1-4 should be filled
    #expect(november.prefix(4).allSatisfy { $0 == "█" })
    // Days 6+ should be empty
    #expect(november.dropFirst(5).allSatisfy { $0 == "░" })
  }

  @Test("without today symbol, today shows as filled")
  func withoutTodaySymbolShowsAsFilled() {
    let config = YearGrid.Configuration.modern()
    let grid = makeGrid(month: 11, day: 5, configuration: config)
    let lines = grid.render().split(separator: "\n")
    let november = String(lines[10])

    // Day 5 should be filled, not a special marker
    #expect(november[november.index(november.startIndex, offsetBy: 4)] == "█")
  }

  // MARK: - Month Labels

  @Test("month labels appear when enabled")
  func monthLabelsAppearWhenEnabled() {
    var config = YearGrid.Configuration.modern()
    config.showMonthLabels = true

    let grid = makeGrid(month: 6, day: 15, configuration: config)
    let lines = grid.render().split(separator: "\n")

    #expect(String(lines[0]).hasPrefix("Jan "))
    #expect(String(lines[1]).hasPrefix("Feb "))
    #expect(String(lines[5]).hasPrefix("Jun "))
    #expect(String(lines[11]).hasPrefix("Dec "))
  }

  @Test("month labels do not appear when disabled")
  func monthLabelsDoNotAppearWhenDisabled() {
    var config = YearGrid.Configuration.modern()
    config.showMonthLabels = false

    let grid = makeGrid(month: 6, day: 15, configuration: config)
    let lines = grid.render().split(separator: "\n")

    // First line should start with a symbol, not a letter
    let firstChar = lines[0].first!
    #expect(firstChar == "█" || firstChar == "░")
  }

  // MARK: - Custom Symbols

  @Test("custom symbols are respected")
  func customSymbolsAreRespected() {
    let config = YearGrid.Configuration(
      filledSymbol: "x",
      emptySymbol: "o"
    )
    let grid = makeGrid(month: 6, day: 15, configuration: config)
    let output = grid.render()

    #expect(output.contains("x"))
    #expect(output.contains("o"))
    #expect(!output.contains("█"))
    #expect(!output.contains("░"))
  }

  @Test("ASCII preset uses x and o")
  func asciiPresetUsesXAndO() {
    let config = YearGrid.Configuration.ascii()
    let grid = makeGrid(month: 6, day: 15, configuration: config)
    let output = grid.render()

    #expect(output.contains("x"))
    #expect(output.contains("o"))
  }

  // MARK: - Edge Cases

  @Test("viewing past year shows all filled")
  func viewingPastYearShowsAllFilled() {
    let grid = makeGrid(year: 2020, month: 6, day: 15, referenceYear: 2025)
    let output = grid.render()
    #expect(output.allSatisfy { $0 == "█" || $0 == "\n" })
  }

  @Test("viewing future year shows all empty")
  func viewingFutureYearShowsAllEmpty() {
    let grid = makeGrid(year: 2030, month: 6, day: 15, referenceYear: 2025)
    let output = grid.render()
    #expect(output.allSatisfy { $0 == "░" || $0 == "\n" })
  }

  // MARK: - Title Integration

  @Test("grid with title on left indents all rows")
  func gridWithTitleLeftIndentsRows() {
    let grid = makeGrid(month: 3, day: 15)
    let output = grid.render()
    let withTitle = TitlePosition.left.render(title: "2025", with: output)
    let lines = withTitle.split(separator: "\n", omittingEmptySubsequences: false)

    // First line should start with title
    #expect(lines[0].hasPrefix("2025 "))
    // All subsequent lines should be indented by 5 spaces (4 chars + 1 space)
    for line in lines.dropFirst() {
      #expect(line.hasPrefix("     "), "Line should be indented: \(line)")
    }
  }

  @Test("grid with title above does not indent rows")
  func gridWithTitleAboveNoIndent() {
    let grid = makeGrid(month: 3, day: 15)
    let output = grid.render()
    let withTitle = TitlePosition.above.render(title: "2025", with: output)
    let lines = withTitle.split(separator: "\n", omittingEmptySubsequences: false)

    // First line is the title
    #expect(lines[0] == "2025")
    // Grid lines should not be indented
    #expect(lines[1].first == "█" || lines[1].first == "░")
  }

  @Test("grid with month labels and title on left aligns correctly")
  func gridWithMonthLabelsAndTitleLeft() {
    var config = YearGrid.Configuration.modern()
    config.showMonthLabels = true
    let grid = makeGrid(month: 3, day: 15, configuration: config)
    let output = grid.render()
    let withTitle = TitlePosition.left.render(title: "Year", with: output)
    let lines = withTitle.split(separator: "\n", omittingEmptySubsequences: false)

    // First line: "Year Jan ████..."
    #expect(lines[0].hasPrefix("Year Jan "))
    // Second line should be indented: "     Feb ████..."
    #expect(lines[1].hasPrefix("     Feb "))
  }

  // MARK: - Helpers

  private static let testTimeZone = TimeZone(identifier: "America/Los_Angeles")!

  private func makeTestCalendar() -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = Self.testTimeZone
    calendar.locale = Locale(identifier: "en_US")
    return calendar
  }

  private func makeGrid(
    year: Int = 2025,
    month: Int,
    day: Int,
    referenceYear: Int? = nil,
    configuration: YearGrid.Configuration = .modern()
  ) -> YearGrid {
    let calendar = makeTestCalendar()
    var components = DateComponents(year: referenceYear ?? year, month: month, day: day)
    components.timeZone = Self.testTimeZone
    let date = calendar.date(from: components)!

    return YearGrid(
      year: year,
      referenceDate: date,
      calendar: calendar,
      configuration: configuration
    )
  }
}
