//
//  AppCoordinator.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import SwiftUI

@Observable
@MainActor
public final class AppCoordinator {
    private let dependencies: AppExternalDependencies

    var path = NavigationPath()
    var sheet: AppSheet?

    public init(dependencies: AppExternalDependencies) {
        self.dependencies = dependencies
    }

    func makeRoot() -> some View {
        DashboardFactory.build(dependencies: dependencies)
    }

    @ViewBuilder
    func makeSheet(_ sheet: AppSheet) -> some View {
        switch sheet {
        case .newMatch:
            NewMatchFactory.build(dependencies: dependencies)
        }
    }

    func dismissSheet() {
        sheet = nil
    }
}

extension AppCoordinator: AppCoordinatorProtocol {}

extension AppCoordinator: DashboardRouting {
    public func showNewMatch() {
        sheet = .newMatch
    }
}

extension AppCoordinator: NewMatchRouting {
    public func closeNewMatch() {
        dismissSheet()
    }

    public func newMatchDidFinish() {
        dismissSheet()
    }
}

public protocol AppExternalDependencies: DashboardExternalDependencies, NewMatchExternalDependencies {}
