//
//  ChartzLegendView.swift
//  Chartzs
//
//  Created by José María Jiménez on 21/11/2026.
//

import SwiftUI

struct ChartzLegendView: View {

    enum C {
        static var dotSize: CGFloat { 10 }
    }

    private let legend: Chartz.Legend
    private let viewData: Chartz.ViewData

    init(legend: Chartz.Legend, viewData: Chartz.ViewData) {
        self.legend = legend
        self.viewData = viewData
    }

    var body: some View {
        VStack(spacing: legend.spacing) {
            ForEach(legend.items.enumerated(), id: \.offset) { index, item in
                HStack {
                    Circle()
                        .fill(viewData.color(at: index))
                        .frame(width: C.dotSize, height: C.dotSize)
                        .accessibilityHidden(true)
                    Text(item.label)
                    Spacer()
                    if let detail = item.detail {
                        Text(detail)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

#if DEBUG

#Preview {
    ChartzLegendView(
        legend: Chartz.Legend(items: [
            .init(label: "Mercedes", detail: "8 · 40 %"),
            .init(label: "Dani", detail: "6 · 30 %"),
            .init(label: "Lucía")
        ]),
        viewData: Chartz.ViewData(items: [8, 6, 2], spacing: 2, innerRadius: .ratio(0.6))
    )
    .padding()
}

#endif
