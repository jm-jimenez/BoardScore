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
    var body: some View {
        Chartz(viewData:
                Chartz.ViewData(
                    items: data.map { Double($0.value) },
                    spacing: 2,
                    innerRadius: .ratio(0.6)
                )
        )
    }
}

#if DEBUG

#Preview {
    ChartView()
}

#endif
