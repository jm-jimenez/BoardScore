//
//  AppCoordinator.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import SwiftUI
import BoardScoreDomain

@Observable
@MainActor
public final class AppCoordinator {
    private let dependencies: AppExternalDependencies

    var path = NavigationPath()
    var sheet: AppSheet?
    var nestedSheet: AppSheet?
    var section: AppSection = .dashboard
    var isSideMenuPresented = false

    public init(dependencies: AppExternalDependencies) {
        self.dependencies = dependencies
    }

    @ViewBuilder
    func makeRoot() -> some View {
        switch section {
        case .dashboard:
            DashboardFactory.build(dependencies: dependencies)
        case .games:
            GamesFactory.build()
        case .players:
            PlayersFactory.build()
        }
    }

    func showSideMenu() {
        isSideMenuPresented = true
    }

    func hideSideMenu() {
        isSideMenuPresented = false
    }

    func select(_ section: AppSection) {
        if self.section != section {
            path = NavigationPath()
            self.section = section
        }
        hideSideMenu()
    }

    @ViewBuilder
    func makeSheet(_ sheet: AppSheet) -> some View {
        switch sheet {
        case .newMatch(let onFinish):
            NewMatchFactory.build(dependencies: dependencies, onFinish: onFinish)
        case .newGame(let onCreate):
            NewGameFactory.build(dependencies: dependencies, onCreate: onCreate)
        }
    }

    func dismissSheet() {
        dismissNestedSheet()
        sheet = nil
    }

    func dismissNestedSheet() {
        nestedSheet = nil
    }
}

extension AppCoordinator: AppCoordinatorProtocol {}

extension AppCoordinator: DashboardRouting {
    public func showNewMatch(onFinish: @escaping @MainActor () -> Void) {
        sheet = .newMatch(onFinish: onFinish)
    }
}

extension AppCoordinator: NewMatchRouting {
    public func closeNewMatch() {
        dismissSheet()
    }

    public func newMatchDidFinish() {
        dismissSheet()
    }

    public func showNewGame(onCreate: @escaping @MainActor (Domain.GameModel) -> Void) {
        nestedSheet = .newGame(onCreate: onCreate)
    }
}

extension AppCoordinator: NewGameRouting {
    public func closeNewGame() {
        dismissNestedSheet()
    }

    public func newGameDidFinish() {
        dismissNestedSheet()
    }
}

public protocol AppExternalDependencies: DashboardExternalDependencies,
                                         NewMatchExternalDependencies,
                                         NewGameExternalDependencies {}
