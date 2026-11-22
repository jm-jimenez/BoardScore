//
//  GameStatsView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import SwiftUI

struct GameStatsView: View {
    struct ViewData: Equatable {
        let rows: [GameStatRowView.ViewData]
    }

    enum C {
        static var spacing: CGFloat { 12 }
    }

    private let viewData: ViewData

    init(viewData: ViewData) {
        self.viewData = viewData
    }

    var body: some View {
        VStack(spacing: C.spacing) {
            Text("Statistics".localized)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .unredacted()
            Divider()
            ForEach(viewData.rows.enumerated(), id: \.offset) { index, row in
                GameStatRowView(viewData: row)
                if index < viewData.rows.count - 1 {
                    Divider()
                }
            }
        }
        .dashboardCard()
    }
}

#if DEBUG

#Preview {
    GameStatsView(viewData: GameStatsViewData.mock.stats)
        .padding()
        .background { Color(uiColor: .systemGroupedBackground) }
}

#endif
