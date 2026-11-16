//
//  NewMatchResult.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation
import BoardScoreDomain

struct NewMatchResult: Equatable {
    let game: Domain.GameModel
    let date: Date
    let durationMinutes: Int?
    let isWinnerManuallySelected: Bool
    let participants: [Participant]

    struct Participant: Equatable {
        let player: Domain.PlayerModel
        let turnOrder: Int
        let scores: [Domain.ScoreableModel: Int]
        let total: Int
        let isWinner: Bool
    }
}
