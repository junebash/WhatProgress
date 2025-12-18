# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WhatProgress is a Swift command-line tool that displays progress through time periods (day, week, month, year, lifetime) or custom ranges as visual progress bars. Built with Swift Package Manager and uses the ArgumentParser library.

## Build & Test Commands

This project uses `just` for common tasks:

```bash
# Build the project
just build

# Build release version
just release

# Run tests (uses Swift Testing framework, not XCTest)
just test

# Run a specific test
just test --filter "ProgressCalculatorTests"

# Run the executable
just run --help
just run -p year
just run -s 0 -c 50 -e 100 -t "Progress"

# Install/uninstall
just install    # Installs to ~/.local/bin/whatprogress
just uninstall

# Clean build artifacts
just clean
```

## Architecture

The codebase follows a separation between core logic and CLI interface:

### Module Structure

- **WhatProgressCore**: Pure Swift library with no dependencies
  - Contains all business logic, calculations, and rendering
  - `Arguments`: Input data structure (independent of ArgumentParser)
  - `ParsedArguments`: Internal representation after validation
  - `ProgressCalculator`: Computes progress percentages for presets and custom ranges
  - `ProgressBar`: Renders visual progress bars with different styles
  - `Environment`: Dependency injection for Date/Calendar/TimeZone (enables testing)

- **WhatProgress**: Executable target
  - Thin CLI layer using ArgumentParser
  - `WhatProgress.swift`: ParsableCommand that validates input and delegates to WhatProgressCore

### Key Design Patterns

- **Dependency Injection**: `Environment` struct wraps `Date`, `Calendar`, `TimeZone`, and `Locale` so tests can use fixed values
- **Error Handling**: Uses typed throws (`throws(WhatProgressError)`) for explicit error handling
- **Two-Stage Parsing**: CLI arguments → `Arguments` → `ParsedArguments` → rendering
  - First stage (`Arguments`) is ArgumentParser-agnostic for testability
  - Second stage (`ParsedArguments`) does validation and date parsing

### Testing

- Uses Swift Testing framework (`import Testing`, not XCTest)
- Tests use deterministic timezone (`America/Los_Angeles`) and locale (`en_US`)
- All time-dependent tests inject fixed `Environment` values
