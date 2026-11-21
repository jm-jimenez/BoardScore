//
//  AppSheet.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import BoardScoreDomain

enum AppSheet: Identifiable, Equatable {
    case newMatch(onFinish: @MainActor () -> Void)
    case newGame(onCreate: @MainActor (Domain.GameModel) -> Void)

    var id: String {
        switch self {
        case .newMatch: "newMatch"
        case .newGame: "newGame"
        }
    }

    static func == (lhs: AppSheet, rhs: AppSheet) -> Bool {
        lhs.id == rhs.id
    }
}
