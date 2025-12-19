# WhatProgress CLI - Progress bar tool

# Default recipe
default: build

# Build the project
build *args:
  swift build {{args}}

# Build release version
release:
  swift build -c release

# Run tests
test *args:
  swift test {{args}}

# Run the CLI with arguments
run *args:
  swift run WhatProgress {{args}}

# Install to ~/.local/bin (commonly in PATH)
install: release
  @mkdir -p ~/.local/bin
  @cp .build/release/WhatProgress ~/.local/bin/whatprogress
  @echo "Installed to ~/.local/bin/whatprogress"
  @echo "Make sure ~/.local/bin is in your PATH"

# Uninstall
uninstall:
  @rm -f ~/.local/bin/whatprogress
  @echo "Removed ~/.local/bin/whatprogress"

# Clean build artifacts
clean:
  swift package clean

# Create a new release tag (example: just tag 1.0.0)
tag version:
  @echo "Creating release v{{version}}"
  @git tag -a "v{{version}}" -m "Release v{{version}}"
  @echo "Tag created. Push with: git push origin v{{version}}"
  @echo "This will trigger the GitHub Actions release workflow."
