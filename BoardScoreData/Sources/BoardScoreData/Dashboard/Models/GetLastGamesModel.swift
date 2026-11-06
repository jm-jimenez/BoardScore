//
//  GetLastGamesModel.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 07/11/2026.
//

import Foundation

public extension Data {
    struct GetLastGamesModel {
        public let name: String
        public let winner: String
        public let date: Date

        public init(
            name: String,
            winner: String,
            date: Date
        ) {
            self.name = name
            self.winner = winner
            self.date = date
        }
    }
}
