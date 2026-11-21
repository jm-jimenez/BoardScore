//
//  PlayersFactory.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import SwiftUI

@MainActor
struct PlayersFactory {
    static func build() -> some View {
        PlayersView()
    }
}
