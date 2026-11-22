//
//  GamesViewModelProtocol.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import Foundation
import BoardScoreDomain

@MainActor
protocol GamesViewModelProtocol: AnyObject, Observable {
    var state: GamesViewModelState { get }
    var games: [Domain.GameModel] { get }
    var selectedGame: Domain.GameModel? { get }

    func onAppear() async
    func selectGame(_ game: Domain.GameModel)
}

enum GamesViewModelState: Equatable {
    case idle
    case loading
    case content(GameStatsViewData)
    case noGames
    case notPlayed
    case error

    var isContent: Bool {
        switch self {
        case .content: true
        default: false
        }
    }
}

struct GameStatsViewData: Equatable {
    let winners: WinnersChartView.ViewData
    let stats: GameStatsView.ViewData
}
