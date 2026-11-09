// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Chartzs",
    platforms: [.iOS(.v27)],
    products: [
        .library(
            name: "Chartzs",
            targets: ["Chartzs"]
        )
    ],
    targets: [
        .target(
            name: "Chartzs",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ]
        )
    ]
)
