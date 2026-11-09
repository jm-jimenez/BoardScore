//
//  GetTopWinnersModel.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 09/11/2026.
//

public extension Domain {
    struct GetTopWinnersModel: Sendable {
        public let name: String
        public let lastGameWin: String
        public let wins: Int
        public let losses: Int

        public init(name: String, lastGameWin: String, wins: Int, losses: Int) {
            self.name = name
            self.lastGameWin = lastGameWin
            self.wins = wins
            self.losses = losses
        }
    }
}
