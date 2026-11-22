//
//  DashboardPlaceholder.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 10/11/2026.
//

extension DashboardViewModelState.ContentData {
    static var placeholder: Self {
        typealias LastGame = LastGamesView.ViewData.LastGame
        typealias WinnerSummary = TopWinnersView.ViewData.WinnerSummary

        return Self(
            gamesViewData: LastGamesView.ViewData(items: [
                LastGame(name: "Placeholder game", winner: "Player", date: "00/00/0000"),
                LastGame(name: "Board game", winner: "Player name", date: "00/00/0000"),
                LastGame(name: "Longer game name", winner: "Name", date: "00/00/0000")
            ]),
            winnersViewData: TopWinnersView.ViewData(items: [
                WinnerSummary(name: "Player name", lastGame: "Board game", winsLosses: "00 / 00"),
                WinnerSummary(name: "Player", lastGame: "Longer game name", winsLosses: "00 / 00"),
                WinnerSummary(name: "Name", lastGame: "Game", winsLosses: "00 / 00")
            ])
        )
    }
}
