import Foundation
import Testing

@testable import WhatProgress

@Suite("ProgressBar Rendering")
struct ProgressBarTests {

  // MARK: - Basic Rendering

  @Test("renders progress bar with correct percentage format")
  func rendersPercentageWithOneDecimal() {
    // 58.4% of 20 blocks = 11.68 blocks
    // 11 full blocks + 68% of next block (in 50-83% range) shows ▓
    let bar = ProgressBar(progress: 0.584)
    #expect(bar.render() == "[███████████▓░░░░░░░░] 58.4%")
  }

  @Test("renders 0% progress correctly")
  func rendersZeroProgress() {
    let bar = ProgressBar(progress: 0.0)
    #expect(bar.render() == "[░░░░░░░░░░░░░░░░░░░░] 0.0%")
  }

  @Test("renders 100% progress correctly")
  func rendersFullProgress() {
    let bar = ProgressBar(progress: 1.0)
    #expect(bar.render() == "[████████████████████] 100.0%")
  }

  @Test("renders overflow progress (>100%) correctly")
  func rendersOverflowProgress() {
    let bar = ProgressBar(progress: 1.053)
    #expect(bar.render() == "[████████████████████] 105.3%")
  }

  @Test("clamps underflow to 0%")
  func clampsUnderflowProgress() {
    let bar = ProgressBar(progress: -0.5)
    #expect(bar.render() == "[░░░░░░░░░░░░░░░░░░░░] 0.0%")
  }

  // MARK: - Unicode vs ASCII

  @Test("renders Unicode bar with modern style")
  func rendersUnicodeWithModernStyle() {
    let bar = ProgressBar(progress: 0.5, style: .barFill(.modern()))
    #expect(bar.render() == "[██████████░░░░░░░░░░] 50.0%")
  }

  @Test("renders ASCII bar when requested")
  func rendersAsciiWhenRequested() {
    let bar = ProgressBar(progress: 0.5, style: .barFill(.ascii()))
    #expect(bar.render() == "[##########..........] 50.0%")
  }

  // MARK: - Bar Width

  @Test("respects custom width")
  func respectsCustomWidth() {
    let bar = ProgressBar(progress: 0.5, style: .barFill(.modern(width: 10)))
    #expect(bar.render() == "[█████░░░░░] 50.0%")
  }

  @Test("default width is 20")
  func defaultWidthIs20() {
    let bar = ProgressBar(progress: 0.25)
    #expect(bar.render() == "[█████░░░░░░░░░░░░░░░] 25.0%")
  }

  // MARK: - Title Rendering

  @Test("renders without title when none provided")
  func rendersWithoutTitle() {
    let bar = ProgressBar(progress: 0.5, title: nil)
    #expect(bar.render() == "[██████████░░░░░░░░░░] 50.0%")
  }

  @Test("renders title to the left when position is left")
  func rendersTitleLeft() {
    let bar = ProgressBar(progress: 0.5, title: "Year", titlePosition: .left)
    #expect(bar.render() == "Year [██████████░░░░░░░░░░] 50.0%")
  }

  @Test("renders title above when position is above")
  func rendersTitleAbove() {
    let bar = ProgressBar(progress: 0.5, title: "Year", titlePosition: .above)
    #expect(bar.render() == "Year\n[██████████░░░░░░░░░░] 50.0%")
  }

  // MARK: - Multi-line Title Rendering

  @Test("title left with multi-line content indents subsequent lines")
  func titleLeftIndentsMultipleLines() {
    let multiLine = "Line1\nLine2\nLine3"
    let result = TitlePosition.left.render(title: "Title", with: multiLine)
    #expect(result == "Title Line1\n      Line2\n      Line3")
  }

  @Test("title left with single line does not add indent")
  func titleLeftSingleLineNoIndent() {
    let singleLine = "OnlyLine"
    let result = TitlePosition.left.render(title: "Test", with: singleLine)
    #expect(result == "Test OnlyLine")
  }

  @Test("title above with multi-line content preserves all lines")
  func titleAbovePreservesMultipleLines() {
    let multiLine = "Line1\nLine2\nLine3"
    let result = TitlePosition.above.render(title: "Header", with: multiLine)
    #expect(result == "Header\nLine1\nLine2\nLine3")
  }

  @Test("title left indent matches title length plus space")
  func titleLeftIndentMatchesTitleLength() {
    let multiLine = "A\nB"
    let result = TitlePosition.left.render(title: "XY", with: multiLine)
    // "XY" is 2 chars + 1 space = 3 spaces indent
    #expect(result == "XY A\n   B")
  }

  @Test("title left with empty lines preserves them")
  func titleLeftPreservesEmptyLines() {
    let withEmpty = "First\n\nThird"
    let result = TitlePosition.left.render(title: "T", with: withEmpty)
    #expect(result == "T First\n  \n  Third")
  }

  // MARK: - Partial Progress Shading

  @Test("partial progress shows 33% shade character")
  func partialProgress33Shade() {
    // With width 10, each block = 10%. At 12%, we have 1 full block + 20% of next block
    // 20% is in the 17-50% range, so it shows ▒ (33% shade)
    let bar = ProgressBar(progress: 0.12, style: .barFill(.modern(width: 10)))
    #expect(bar.render() == "[█▒░░░░░░░░] 12.0%")
  }

  @Test("partial progress shows 67% shade character")
  func partialProgress67Shade() {
    // With width 10, each block = 10%. At 16%, we have 1 full block + 60% of next block
    // 60% is in the 50-83% range, so it shows ▓ (67% shade)
    let bar = ProgressBar(progress: 0.16, style: .barFill(.modern(width: 10)))
    #expect(bar.render() == "[█▓░░░░░░░░] 16.0%")
  }

  @Test("partial progress rounds to full block at 83%+ of block")
  func partialProgressRoundsToFull() {
    // With width 10, each block = 10%. At 19%, we have 1 full block + 90% of next block
    // 90% is >= 83%, so it shows █ (full)
    let bar = ProgressBar(progress: 0.19, style: .barFill(.modern(width: 10)))
    #expect(bar.render() == "[██░░░░░░░░] 19.0%")
  }

  @Test("partial progress shows empty below 17% of block")
  func partialProgressShowsEmpty() {
    // With width 10, each block = 10%. At 11%, we have 1 full block + 10% of next block
    // 10% is < 17%, so no partial character shown
    let bar = ProgressBar(progress: 0.11, style: .barFill(.modern(width: 10)))
    #expect(bar.render() == "[█░░░░░░░░░] 11.0%")
  }

  @Test("ASCII partial progress shows dash for 33% shade")
  func asciiPartialProgress33Shade() {
    // With width 10, each block = 10%. At 12%, we have 1 full block + 20% of next block
    let bar = ProgressBar(progress: 0.12, style: .barFill(.ascii(width: 10)))
    #expect(bar.render() == "[#-........] 12.0%")
  }

  @Test("ASCII partial progress shows equals for 67% shade")
  func asciiPartialProgress67Shade() {
    // With width 10, each block = 10%. At 16%, we have 1 full block + 60% of next block
    let bar = ProgressBar(progress: 0.16, style: .barFill(.ascii(width: 10)))
    #expect(bar.render() == "[#=........] 16.0%")
  }

  @Test("no partial character at exact block boundaries")
  func noPartialAtExactBoundary() {
    // At exactly 50%, no fractional part, so no partial character
    let bar = ProgressBar(progress: 0.5, style: .barFill(.modern(width: 10)))
    #expect(bar.render() == "[█████░░░░░] 50.0%")
  }

  @Test("no partial character at 100%")
  func noPartialAt100Percent() {
    let bar = ProgressBar(progress: 1.0, style: .barFill(.modern(width: 10)))
    #expect(bar.render() == "[██████████] 100.0%")
  }

  @Test("no partial character at 0%")
  func noPartialAt0Percent() {
    let bar = ProgressBar(progress: 0.0, style: .barFill(.modern(width: 10)))
    #expect(bar.render() == "[░░░░░░░░░░] 0.0%")
  }
}
