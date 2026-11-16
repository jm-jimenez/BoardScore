//
//  NewMatchMockGameFactory.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation
import BoardScoreDomain

enum NewMatchMockGameFactory {
    static func make(number: Int) -> Domain.NewGameModel {
        Domain.NewGameModel(
            name: String(format: "Game %lld".localized, number),
            winCondition: .highestScore,
            scoreableNames: ["Points".localized, "Bonus".localized, "Penalty".localized]
        )
    }
}
