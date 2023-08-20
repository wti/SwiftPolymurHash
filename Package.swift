// swift-tools-version:5.7

import PackageDescription

let swiftWrap = "PolymurHash"
let cLib = "_CPolymurHash"

let package = Package(
  name: "Swift\(swiftWrap)",
  products: [
    .library(name: swiftWrap, targets: [swiftWrap]),
  ],
  targets: [
    .target(name: cLib,
    linkerSettings: [.linkedLibrary("m", .when(platforms: [.linux]))]
          ),
    .target(
      name: swiftWrap,
      dependencies: [.target(name: cLib)]
    ),
    .testTarget(
      name: "\(swiftWrap)Tests",
      dependencies: [
        .target(name: swiftWrap)
      ]
    ),
    .testTarget(
      name: "CPolymurHashTests",
      dependencies: [
        .target(name: cLib)
      ]
    ),
  ]
)
