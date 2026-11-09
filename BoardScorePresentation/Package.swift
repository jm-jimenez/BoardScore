// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "BoardScorePresentation",
    platforms: [.iOS(.v27)],
    products: [
        .library(
            name: "BoardScorePresentation",
            targets: ["BoardScorePresentation"]
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
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .testTarget(
            name: "BoardScorePresentationTests",
            dependencies: ["BoardScorePresentation",
                           .product(name: "BoardScoreDomainMocks", package: "BoardScoreDomain")
                          ]
        )
    ]
)
