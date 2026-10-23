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
                    spacing: 0,
                    innerRadius: Space.none
                )
        )
    }
}

#if DEBUG

#Preview {
    ChartView()
}

#endif
