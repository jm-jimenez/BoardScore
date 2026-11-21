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

    public init(dependencies: AppExternalDependencies) {
        self.dependencies = dependencies
    }

    func makeRoot() -> some View {
        DashboardFactory.build(dependencies: dependencies)
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
