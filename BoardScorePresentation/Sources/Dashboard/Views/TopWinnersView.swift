//
//  TopWinnersView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 24/10/2026.
//

import SwiftUI

struct TopWinnersView: View {
    struct ViewData: Equatable {
        let items: [WinnerSummary]

        struct WinnerSummary: Equatable {
            let name: String
            let lastGame: String
            let winsLosses: String
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
            winners
        }
        .dashboardCard()
    }

    var header: some View {
        SectionHeaderView(
            viewData: SectionHeaderView.ViewData(
                title: "Top winners".localized,
                info: "Wins / losses".localized
            )
        )
    }

    var winners: some View {
        VStack(spacing: 12) {
            ForEach(viewData.items.enumerated(), id: \.offset) { index, item in
                SectionItemView(
                    viewData: SectionItemView.ViewData(
                        description: item.name,
                        info: item.lastGame,
                        value: item.winsLosses))

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
                winsLosses: "13 / 6"
            ),
            WinnerSummary(
                name: "M@rio",
                lastGame: "Alquimistas",
                winsLosses: "8 / 3"
            )
        ])
    }
}

#Preview {
    TopWinnersView(viewData: .mock)
        .padding()
        .background { Color(uiColor: .systemGroupedBackground) }
}

#endif
