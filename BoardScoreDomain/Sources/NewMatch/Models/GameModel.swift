//
//  GameModel.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation

public extension Domain {
    struct GameModel: Sendable, Hashable, Identifiable {
        public let id: UUID
        public let name: String
        public let winCondition: WinCondition
        public let scoreables: [ScoreableModel]

        public init(
            id: UUID = UUID(),
            name: String,
            winCondition: WinCondition,
            scoreables: [ScoreableModel]
        ) {
            self.id = id
            self.name = name
            self.winCondition = winCondition
            self.scoreables = scoreables
        }
    }
}
