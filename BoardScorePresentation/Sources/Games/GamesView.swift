//
//  GamesView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import SwiftUI

struct GamesView: View {
    var body: some View {
        Text(verbatim: "hello world")
            .navigationTitle("Games".localized)
    }
}

#if DEBUG

#Preview("Content") {
    NavigationStack {
        GamesView()
    }
}

#endif
