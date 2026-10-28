//
//  TopWinnersView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 24/10/2026.
//

import SwiftUI

struct TopWinnersView: View {
    private enum C {
        static let cornerRadius: CGFloat = 16
    }

    struct ViewData {
        let items: [WinnerSummary]

        struct WinnerSummary {
            let name: String
            let lastGame: String
            let winsLoses: String
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
            winners
        }
        .padding()
        .background { Color.white }
        .cornerRadius(C.cornerRadius)
        .padding()
    }

    var header: some View {
        SectionHeaderView(
            viewData: SectionHeaderView.ViewData(
                title: "Top winners",
                info: "Wins / loses"
            )
        )
    }

    var winners: some View {
        VStack {
            ForEach(viewData.items.enumerated(), id: \.offset) { index, item in
                SectionItemView(
                    viewData: SectionItemView.ViewData(
                        description: item.name,
                        info: item.lastGame,
                        value: item.winsLoses))

                if index < viewData.items.count - 1 {
                    Divider()
                }
            }
        }
    }
}

#if DEBUG

private extension TopWinnersView.ViewData {
    static var mock: Self {
        Self(items: [
            WinnerSummary(
                name: "Mercedes",
                lastGame: "Wingspan",
                winsLoses: "13 / 6"
            ),
            WinnerSummary(
                name: "M@rio",
                lastGame: "Alquimistas",
                winsLoses: "8 / 3"
            )
        ])
    }
}

#Preview {
    TopWinnersView(viewData: .mock)
}

#endif
