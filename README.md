# WhatProgress

A command-line tool that displays progress through time periods as visual progress bars.

## Installation

```bash
just install
```

Installs to `~/.local/bin/whatprogress` (ensure `~/.local/bin` is in your PATH).

## Usage

Show progress through preset time periods:

```bash
whatprogress -p day
whatprogress -p week
whatprogress -p month
whatprogress -p year
whatprogress -p life -b 1990-01-15
```

Show progress through a custom range:

```bash
whatprogress -s 0 -c 50 -e 100 -t "Download"
```

## Development

See [CLAUDE.md](CLAUDE.md) for architecture and development commands.
