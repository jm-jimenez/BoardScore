//
//  NewGameModel.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

public extension Domain {
    struct NewGameModel: Sendable, Equatable {
        public let name: String
        public let winCondition: WinCondition
        public let scoreableNames: [String]

        public init(
            name: String,
            winCondition: WinCondition,
            scoreableNames: [String]
        ) {
            self.name = name
            self.winCondition = winCondition
            self.scoreableNames = scoreableNames
        }
    }
}
