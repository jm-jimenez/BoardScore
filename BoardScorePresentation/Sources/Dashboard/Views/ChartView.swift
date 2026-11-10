//
//  ChartView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import SwiftUI
import Chartzs

let data = [
    (name: "Test", value: 1),
    (name: "gdfgdfg", value: 2)
]

struct ChartView: View {
    @Environment(\.redactionReasons)
    private var redactionReasons

    private var isPlaceholder: Bool {
        redactionReasons.contains(.placeholder)
    }

    var body: some View {
        Chartz(viewData:
                Chartz.ViewData(
                    items: data.map { Double($0.value) },
                    spacing: 2,
                    innerRadius: .ratio(0.6)
                )
        )
        .grayscale(isPlaceholder ? 1 : 0)
        .opacity(isPlaceholder ? 0.3 : 1)
    }
}

#if DEBUG

#Preview {
    ChartView()
}

#endif
