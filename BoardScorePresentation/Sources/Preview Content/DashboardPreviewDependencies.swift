//
//  DashboardPreviewDependencies.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 14/11/2026.
//

#if DEBUG

final class DashboardViewModelMock: DashboardViewModelProtocol {
    let state: DashboardViewModelState

    init(state: DashboardViewModelState = .content(contentData: .mock)) {
        self.state = state
    }

    func onAppear() async {}

    func onAddGameTapped() {}
}

extension DashboardViewModelState.ContentData {
    static var mock: Self {
        Self(
            gamesViewData: LastGamesView.ViewData(items: [
                LastGamesView.ViewData.LastGame(
                    name: "Dominion",
                    winner: "Dani",
                    date: "4 mins ago"
                ),
                LastGamesView.ViewData.LastGame(
                    name: "Pociones",
                    winner: "Mercedes",
                    date: "5 days ago"
                )
            ]),
            winnersViewData: TopWinnersView.ViewData(items: [
                TopWinnersView.ViewData.WinnerSummary(
                    name: "Mercedes",
                    lastGame: "Wingspan",
                    winsLosses: "13 / 6"
                ),
                TopWinnersView.ViewData.WinnerSummary(
                    name: "M@rio",
                    lastGame: "Alquimistas",
                    winsLosses: "8 / 3"
                )
            ])
        )
    }
}

#endif
