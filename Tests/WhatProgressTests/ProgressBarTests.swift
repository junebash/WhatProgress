import Foundation
import Testing

@testable import WhatProgressCore

@Suite("ProgressBar Rendering")
struct ProgressBarTests {

  // MARK: - Basic Rendering

  @Test("renders progress bar with correct percentage format")
  func rendersPercentageWithOneDecimal() {
    let bar = ProgressBar(progress: 0.584)
    #expect(bar.render() == "[████████████░░░░░░░░] 58.4%")
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
    #expect(bar.render() == "[##########----------] 50.0%")
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
}
