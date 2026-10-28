//
//  LastGamesView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 23/10/2026.
//

import SwiftUI

struct LastGamesView: View {

    private enum C {
        static let cornerRadius: CGFloat = 16
    }

    struct ViewData {
        let items: [LastGame]

        struct LastGame {
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
        VStack {
            header
            Divider()
            games
        }
        .padding()
        .background { Color.white }
        .cornerRadius(C.cornerRadius)
        .padding()

    }

    var header: some View {
        SectionHeaderView(
            viewData: SectionHeaderView.ViewData(
                title: "Last games",
                info: "Winner")
        )
    }

    var games: some View {
        VStack {
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
        .background { Color(uiColor: .secondarySystemBackground) }
}

#endif
