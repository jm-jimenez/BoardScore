// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "BoardScoreData",
    platforms: [.iOS(.v27)],
    products: [
        .library(
            name: "BoardScoreData",
            targets: ["BoardScoreData"]
        ),
        .library(
            name: "BoardScoreDataMocks",
            targets: ["BoardScoreDataMocks"]
        )
    ],
    dependencies: [
        .package(path: "../BoardScoreDomain")
    ],
    targets: [
        .target(
            name: "BoardScoreData",
            dependencies: [
                "BoardScoreDomain"
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .target(
            name: "BoardScoreDataMocks",
            dependencies: [
                "BoardScoreData",
                "BoardScoreDomain"
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "BoardScoreDataTests",
            dependencies: [
                "BoardScoreData",
                "BoardScoreDataMocks"
            ]
        )
    ]
)
