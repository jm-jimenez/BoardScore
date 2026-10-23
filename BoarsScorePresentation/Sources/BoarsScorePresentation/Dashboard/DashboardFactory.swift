//
//  DashboardFactory.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import SwiftUI

@MainActor
public struct DashboardFactory {
    public static func build() -> some View {
        let viewModel = DashboardViewModel()
        let view = DashboardView(viewModel: viewModel)
        return view
    }
}
