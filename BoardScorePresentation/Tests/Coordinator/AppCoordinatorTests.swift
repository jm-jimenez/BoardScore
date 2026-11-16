//
//  AppCoordinatorTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import Testing
@testable import BoardScorePresentation

@MainActor
struct AppCoordinatorTests {
    let sut = AppCoordinator(dependencies: DashboardExternalDependenciesTest())

    @Test
    func showNewMatch_ShouldPresentSheet() {
        sut.showNewMatch()
        #expect(sut.sheet == .newMatch)
    }

    @Test
    func closeNewMatch_ShouldDismissSheet() {
        sut.showNewMatch()
        sut.closeNewMatch()
        #expect(sut.sheet == nil)
    }

    @Test
    func newMatchDidFinish_ShouldDismissSheet() {
        sut.showNewMatch()
        sut.newMatchDidFinish()
        #expect(sut.sheet == nil)
    }

    @Test
    func makeRoot_ShouldBuildDashboard() {
        #expect(sut.makeRoot() is DashboardView<DashboardViewModel>)
    }

    @Test
    func makeSheet_ShouldBuildNewMatch() {
        #expect(String(describing: type(of: sut.makeSheet(.newMatch))).contains("NewMatchView<NewMatchViewModel>"))
        #expect(AppSheet.newMatch.id == "newMatch")
    }

    @Test
    func coordinator_ShouldActAsRouterForEveryFeature() {
        let coordinator: AppCoordinatorProtocol = sut
        coordinator.showNewMatch()
        #expect(sut.sheet == .newMatch)
        coordinator.closeNewMatch()
        #expect(sut.sheet == nil)
    }

    @Test
    func factory_ShouldBuildCoordinatorView() {
        #expect(AppCoordinatorFactory.build(coordinator: sut) is AppCoordinatorView)
    }
}
