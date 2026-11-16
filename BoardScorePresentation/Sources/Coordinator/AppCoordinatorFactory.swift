//
//  AppCoordinatorFactory.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import SwiftUI

@MainActor
public struct AppCoordinatorFactory {
    public static func build(coordinator: AppCoordinator) -> some View {
        AppCoordinatorView(coordinator: coordinator)
    }
}
