// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "BoardScoreDomain",
    platforms: [.iOS(.v27)],
    products: [
        .library(
            name: "BoardScoreDomain",
            targets: ["BoardScoreDomain"]
        ),
        .library(
            name: "BoardScoreDomainMocks",
            targets: ["BoardScoreDomainMocks"]
        )
    ],
    targets: [
        .target(
            name: "BoardScoreDomain",
            path: "Sources",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .target(
            name: "BoardScoreDomainMocks",
            dependencies: ["BoardScoreDomain"],
            path: "Mocks"
        ),
        .testTarget(
            name: "BoardScoreDomainTests",
            dependencies: [
                "BoardScoreDomain",
                "BoardScoreDomainMocks"
            ]
        )
    ]
)
