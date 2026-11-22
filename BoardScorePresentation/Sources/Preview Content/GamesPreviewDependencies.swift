//
//  GamesPreviewDependencies.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

#if DEBUG

import Foundation
import BoardScoreDomain

@Observable
final class GamesViewModelMock: GamesViewModelProtocol {
    let state: GamesViewModelState
    let games: [Domain.GameModel]
    private(set) var selectedGame: Domain.GameModel?

    init(
        state: GamesViewModelState = .content(.mock),
        games: [Domain.GameModel] = [.previewWingspan, .previewAzul]
    ) {
        self.state = state
        self.games = games
        self.selectedGame = games.first
    }

    func onAppear() async {}

    func selectGame(_ game: Domain.GameModel) {
        selectedGame = game
    }
}

extension Domain.GameModel {
    static let previewAzul = Domain.GameModel(name: "Azul", winCondition: .highestScore, scoreables: [])
}

extension GameStatsViewData {
    static var mock: Self {
        typealias Slice = WinnersChartView.ViewData.Slice
        typealias Row = GameStatRowView.ViewData
        typealias Entry = GameStatRowView.ViewData.Entry

        return Self(
            winners: WinnersChartView.ViewData(slices: [
                Slice(name: "Mercedes", wins: 8, detail: "8 · 40 %"),
                Slice(name: "Dani", wins: 6, detail: "6 · 30 %"),
                Slice(name: "M@rio", wins: 4, detail: "4 · 20 %"),
                Slice(name: "Lucía", wins: 2, detail: "2 · 10 %")
            ]),
            stats: GameStatsView.ViewData(rows: [
                Row(title: "Times played", value: "20"),
                Row(title: "Highest score", entries: [Entry(player: "Mercedes", value: "112")]),
                Row(title: "Average score", value: "74,5"),
                Row(title: "Top winner", entries: [Entry(player: "Mercedes", value: "8 / 20 · 40 %")]),
                Row(title: "Best win rate", entries: [
                    Entry(player: "Dani", value: "60 % · 6 / 10"),
                    Entry(player: "Lucía", value: "100 % · 2 / 2", note: "Only played 2 matches", isSecondary: true)
                ]),
                Row(title: "Longest win streak", entries: [
                    Entry(player: "Mercedes", value: "4"),
                    Entry(player: "Dani", value: "4")
                ]),
                Row(title: "Most losses", entries: [Entry(player: "M@rio", value: "11")])
            ])
        )
    }
}

#endif
