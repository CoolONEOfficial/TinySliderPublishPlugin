// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "TinySliderPublishPlugin",
    products: [
        .library(
            name: "TinySliderPublishPlugin",
            targets: ["TinySliderPublishPlugin"]
        ),
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", .upToNextMinor(from: "0.8.0")),
    ],
    targets: [
        .target(
            name: "TinySliderPublishPlugin",
            dependencies: ["Publish"]
        ),
        .testTarget(
            name: "TinySliderPublishPluginTests",
            dependencies: ["TinySliderPublishPlugin"]
        ),
    ]
)
