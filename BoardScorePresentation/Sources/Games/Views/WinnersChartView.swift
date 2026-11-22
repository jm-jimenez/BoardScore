//
//  WinnersChartView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import SwiftUI
import Chartzs

struct WinnersChartView: View {
    struct ViewData: Equatable {
        let slices: [Slice]

        struct Slice: Equatable {
            let name: String
            let wins: Int
            let detail: String
        }
    }

    enum C {
        static var chartHeight: CGFloat { 180 }
        static var spacing: CGFloat { 12 }
        static var segmentSpacing: CGFloat { 2 }
        static var innerRadius: Double { 0.6 }
    }

    private let viewData: ViewData

    init(viewData: ViewData) {
        self.viewData = viewData
    }

    var body: some View {
        VStack(spacing: C.spacing) {
            SectionHeaderView(
                viewData: SectionHeaderView.ViewData(
                    title: "Winners".localized,
                    info: "Share of matches".localized
                )
            )
            Divider()
            if viewData.slices.isEmpty {
                Text("Nobody has won yet".localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                chart
            }
        }
        .dashboardCard()
    }
}

private extension WinnersChartView {
    var chart: some View {
        Chartz(
            viewData: Chartz.ViewData(
                items: viewData.slices.map { Double($0.wins) },
                spacing: C.segmentSpacing,
                innerRadius: .ratio(C.innerRadius),
                maxDiameter: C.chartHeight,
                legend: Chartz.Legend(
                    items: viewData.slices.map { Chartz.Legend.Item(label: $0.name, detail: $0.detail) },
                    spacing: C.spacing
                )
            )
        )
    }
}

#if DEBUG

#Preview("Content") {
    WinnersChartView(viewData: GameStatsViewData.mock.winners)
        .padding()
        .background { Color(uiColor: .systemGroupedBackground) }
}

#Preview("No winners") {
    WinnersChartView(viewData: .init(slices: []))
        .padding()
        .background { Color(uiColor: .systemGroupedBackground) }
}

#endif
