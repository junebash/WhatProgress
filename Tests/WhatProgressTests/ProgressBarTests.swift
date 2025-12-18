import Foundation
import Testing

@testable import WhatProgressCore

@Suite("ProgressBar Rendering")
struct ProgressBarTests {

  // MARK: - Basic Rendering

  @Test("renders progress bar with correct percentage format")
  func rendersPercentageWithOneDecimal() {
    let bar = ProgressBar(progress: 0.584)
    let output = bar.render()
    #expect(output.contains("58.4%"))
  }

  @Test("renders 0% progress correctly")
  func rendersZeroProgress() {
    let bar = ProgressBar(progress: 0.0)
    let output = bar.render()
    #expect(output.contains("0.0%"))
  }

  @Test("renders 100% progress correctly")
  func rendersFullProgress() {
    let bar = ProgressBar(progress: 1.0)
    let output = bar.render()
    #expect(output.contains("100.0%"))
  }

  @Test("renders overflow progress (>100%) correctly")
  func rendersOverflowProgress() {
    let bar = ProgressBar(progress: 1.053)
    let output = bar.render()
    #expect(output.contains("105.3%"))
  }

  @Test("clamps underflow to 0%")
  func clampsUnderflowProgress() {
    let bar = ProgressBar(progress: -0.5)
    let output = bar.render()
    #expect(output.contains("0.0%"))
  }

  // MARK: - Unicode vs ASCII

  @Test("renders Unicode bar by default")
  func rendersUnicodeByDefault() {
    let bar = ProgressBar(progress: 0.5, useAscii: false)
    let output = bar.render()
    #expect(output.contains("█") || output.contains("░"))
  }

  @Test("renders ASCII bar when requested")
  func rendersAsciiWhenRequested() {
    let bar = ProgressBar(progress: 0.5, useAscii: true)
    let output = bar.render()
    #expect(output.contains("#") || output.contains("-"))
    #expect(!output.contains("█"))
    #expect(!output.contains("░"))
  }

  // MARK: - Bar Width

  @Test("respects custom width")
  func respectsCustomWidth() {
    let bar = ProgressBar(progress: 0.5, width: 10)
    let output = bar.render()
    // Should have 10 bar characters between brackets
    // Count filled + empty characters
    let barContent = extractBarContent(from: output)
    #expect(barContent.count == 10)
  }

  @Test("default width is 20")
  func defaultWidthIs20() {
    let bar = ProgressBar(progress: 0.5)
    let output = bar.render()
    let barContent = extractBarContent(from: output)
    #expect(barContent.count == 20)
  }

  // MARK: - Title Rendering

  @Test("renders without title when none provided")
  func rendersWithoutTitle() {
    let bar = ProgressBar(progress: 0.5, title: nil)
    let output = bar.render()
    #expect(!output.contains("\n") || output.trimmingCharacters(in: .whitespacesAndNewlines) == output.trimmingCharacters(in: .newlines))
  }

  @Test("renders title to the left when position is left")
  func rendersTitleLeft() {
    let bar = ProgressBar(progress: 0.5, title: "Year", titlePosition: .left)
    let output = bar.render()
    #expect(output.hasPrefix("Year "))
    #expect(!output.contains("\n"))
  }

  @Test("renders title above when position is above")
  func rendersTitleAbove() {
    let bar = ProgressBar(progress: 0.5, title: "Year", titlePosition: .above)
    let output = bar.render()
    let lines = output.split(separator: "\n")
    #expect(lines.count == 2)
    #expect(lines[0] == "Year")
  }

  // MARK: - Helper

  private func extractBarContent(from output: String) -> String {
    guard let openBracket = output.firstIndex(of: "["),
          let closeBracket = output.firstIndex(of: "]") else {
      return ""
    }
    let start = output.index(after: openBracket)
    return String(output[start..<closeBracket])
  }
}
