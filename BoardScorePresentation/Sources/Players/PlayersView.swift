//
//  PlayersView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import SwiftUI

struct PlayersView: View {
    var body: some View {
        Text(verbatim: "hello world")
            .navigationTitle("Players".localized)
    }
}

#if DEBUG

#Preview("Content") {
    NavigationStack {
        PlayersView()
    }
}

#endif
