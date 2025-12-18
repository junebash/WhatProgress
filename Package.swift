// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "WhatProgress",
  platforms: [.macOS(.v15)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
  ],
  targets: [
    .target(
      name: "WhatProgressCore"
    ),
    .executableTarget(
      name: "WhatProgress",
      dependencies: [
        "WhatProgressCore",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .testTarget(
      name: "WhatProgressTests",
      dependencies: ["WhatProgressCore"]
    ),
  ]
)
