//
//  GetLastGamesModel.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 06/11/2026.
//

import Foundation

public extension Domain {
    struct GetLastGamesModel: Sendable {
        public let name: String
        public let winner: String
        public let date: Date

        public init(name: String, winner: String, date: Date) {
            self.name = name
            self.winner = winner
            self.date = date
        }
    }
}
