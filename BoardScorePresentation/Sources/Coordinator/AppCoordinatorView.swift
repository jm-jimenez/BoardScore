//
//  AppCoordinatorView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import SwiftUI

struct AppCoordinatorView: View {
    @State private var coordinator: AppCoordinator

    init(coordinator: AppCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.makeRoot()
        }
        .sheet(item: $coordinator.sheet) { sheet in
            coordinator.makeSheet(sheet)
                .sheet(item: $coordinator.nestedSheet) { nestedSheet in
                    coordinator.makeSheet(nestedSheet)
                }
        }
    }
}
