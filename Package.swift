// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "WhatProgress",
  platforms: [
    .macOS(.v15),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: Version(1, 7, 0)),
    .package(url: "https://github.com/pointfreeco/swift-case-paths", from: Version(1, 7, 2)),
  ],
  targets: [
    .executableTarget(
      name: "WhatProgress",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "CasePaths", package: "swift-case-paths"),
      ]
    ),
    .testTarget(
      name: "WhatProgressTests",
      dependencies: [
        "WhatProgress",
      ]
    ),
  ]
)
