// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "TinySliderPublishPlugin",
    platforms: [.macOS(.v12), .iOS(.v13)],
    products: [
        .library(
            name: "TinySliderPublishPlugin",
            targets: ["TinySliderPublishPlugin"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/Publish.git", from: "0.9.0"),
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
