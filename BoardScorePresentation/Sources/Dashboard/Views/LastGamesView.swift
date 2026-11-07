//
//  LastGamesView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 23/10/2026.
//

import SwiftUI

struct LastGamesView: View {

    struct ViewData: Equatable {
        let items: [LastGame]

        struct LastGame: Equatable {
            let name: String
            let winner: String
            let date: String

            init(name: String, winner: String, date: String) {
                self.name = name
                self.winner = winner
                self.date = date
            }
        }
    }

    private let viewData: ViewData

    init(viewData: ViewData) {
        self.viewData = viewData
    }

    var body: some View {
        VStack(spacing: 12) {
            header
            Divider()
            games
        }
        .dashboardCard()
    }

    var header: some View {
        SectionHeaderView(
            viewData: SectionHeaderView.ViewData(
                title: "Last games",
                info: "Winner")
        )
    }

    var games: some View {
        VStack(spacing: 12) {
            ForEach(viewData.items.enumerated(), id: \.offset) { index, game in
                SectionItemView(
                    viewData: SectionItemView.ViewData(
                        description: game.name,
                        info: game.date,
                        value: game.winner
                    )
                )

                if index < viewData.items.count - 1 {
                    Divider()
                }
            }
        }
    }
}


#if DEBUG

private extension LastGamesView.ViewData {
    static var mock: Self {
        Self(items: [
            LastGame(
                name: "Dominion",
                winner: "Dani",
                date: "4 mins ago"
            ),
            LastGame(
                name: "Pociones",
                winner: "Mercedes",
                date: "5 days ago"
            )
        ])
    }
}

#Preview {
    LastGamesView(viewData: .mock)
        .padding()
        .background { Color(uiColor: .systemGroupedBackground) }
}

#endif
