// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "BoardScorePresentation",
    defaultLocalization: "en",
    platforms: [.iOS(.v27)],
    products: [
        .library(
            name: "BoardScorePresentation",
            targets: ["BoardScorePresentation"]
        ),
        .library(
            name: "BoardScorePresentationMocks",
            targets: ["BoardScorePresentationMocks"]
        )
    ],
    dependencies: [
        .package(path: "../BoardScoreDomain"),
        .package(path: "../Chartzs")
    ],
    targets: [
        .target(
            name: "BoardScorePresentation",
            dependencies: ["BoardScoreDomain", "Chartzs"],
            path: "Sources",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .target(
            name: "BoardScorePresentationMocks",
            dependencies: [
                "BoardScorePresentation",
                "BoardScoreDomain"
            ],
            path: "Mocks"
        ),
        .testTarget(
            name: "BoardScorePresentationTests",
            dependencies: ["BoardScorePresentation",
                           "BoardScorePresentationMocks",
                           .product(name: "BoardScoreDomainMocks", package: "BoardScoreDomain")
                          ]
        )
    ]
)
