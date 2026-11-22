//
//  AppCoordinatorTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import Testing
import BoardScoreDomain
import BoardScoreDomainMocks
@testable import BoardScorePresentation

@MainActor
struct AppCoordinatorTests {
    let sut = AppCoordinator(dependencies: DashboardExternalDependenciesTest())

    @Test
    func showNewMatch_ShouldPresentSheet() {
        sut.showNewMatch {}
        #expect(sut.sheet == .newMatch {})
    }

    @Test
    func closeNewMatch_ShouldDismissSheet() {
        sut.showNewMatch {}
        sut.closeNewMatch()
        #expect(sut.sheet == nil)
    }

    @Test
    func newMatchDidFinish_ShouldDismissSheet() {
        sut.showNewMatch {}
        sut.newMatchDidFinish()
        #expect(sut.sheet == nil)
    }

    @Test
    func showNewGame_ShouldPresentNestedSheetCarryingTheClosure() {
        var createdGame: Domain.GameModel?
        let azul = Domain.GameModel.mock(name: "Azul")
        sut.showNewMatch {}

        sut.showNewGame { createdGame = $0 }

        #expect(sut.sheet == .newMatch {})
        guard case .newGame(let onCreate) = sut.nestedSheet else {
            Issue.record("Expected .newGame nested sheet, got \(String(describing: sut.nestedSheet))")
            return
        }

        onCreate(azul)
        #expect(createdGame == azul)
    }

    @Test
    func newGameDidFinish_ShouldDismissNestedSheet() {
        sut.showNewMatch {}
        sut.showNewGame { _ in }

        sut.newGameDidFinish()

        #expect(sut.nestedSheet == nil)
        #expect(sut.sheet == .newMatch {})
    }

    @Test
    func closeNewGame_ShouldDismissNestedSheet() {
        sut.showNewMatch {}
        sut.showNewGame { _ in }

        sut.closeNewGame()

        #expect(sut.nestedSheet == nil)
        #expect(sut.sheet == .newMatch {})
    }

    @Test
    func closeNewMatch_ShouldAlsoDismissNestedSheet() {
        sut.showNewMatch {}
        sut.showNewGame { _ in }

        sut.closeNewMatch()

        #expect(sut.nestedSheet == nil)
        #expect(sut.sheet == nil)
    }

    @Test
    func makeRoot_ShouldBuildDashboard() {
        #expect(sut.section == .dashboard)
        #expect(rootDescription.contains("DashboardView<DashboardViewModel>"))
    }

    @Test
    func makeRoot_WhenGamesSelected_ShouldBuildGames() {
        sut.select(.games)
        #expect(rootDescription.contains("GamesView"))
    }

    @Test
    func makeRoot_WhenPlayersSelected_ShouldBuildPlayers() {
        sut.select(.players)
        #expect(rootDescription.contains("PlayersView"))
    }

    @Test
    func showSideMenu_ShouldPresentSideMenu() {
        sut.showSideMenu()
        #expect(sut.isSideMenuPresented)
    }

    @Test
    func hideSideMenu_ShouldDismissSideMenu() {
        sut.showSideMenu()
        sut.hideSideMenu()
        #expect(sut.isSideMenuPresented == false)
    }

    @Test
    func select_ShouldChangeSectionResetPathAndHideSideMenu() {
        sut.path.append("detail")
        sut.showSideMenu()

        sut.select(.players)

        #expect(sut.section == .players)
        #expect(sut.path.isEmpty)
        #expect(sut.isSideMenuPresented == false)
    }

    @Test
    func select_WhenSameSection_ShouldKeepPathAndHideSideMenu() {
        sut.path.append("detail")
        sut.showSideMenu()

        sut.select(.dashboard)

        #expect(sut.section == .dashboard)
        #expect(sut.path.count == 1)
        #expect(sut.isSideMenuPresented == false)
    }

    @Test
    func appSection_ShouldExposeTitleAndImageForEverySection() {
        #expect(AppSection.allCases == [.dashboard, .games, .players])
        #expect(AppSection.allCases.map(\.title) == ["Dashboard".localized, "Games".localized, "Players".localized])
        #expect(AppSection.allCases.map(\.systemImage) == ["chart.bar.xaxis", "dice", "person.2"])
        #expect(AppSection.games.id == .games)
    }

    @Test
    func factories_ShouldBuildGamesAndPlayers() {
        #expect(GamesFactory.build(dependencies: DashboardExternalDependenciesTest()) is GamesView<GamesViewModel>)
        #expect(PlayersFactory.build() is PlayersView)
    }

    @Test
    func showNewMatch_ShouldPresentSheetCarryingTheClosure() {
        var finishCount = 0

        sut.showNewMatch { finishCount += 1 }

        guard case .newMatch(let onFinish) = sut.sheet else {
            Issue.record("Expected .newMatch sheet, got \(String(describing: sut.sheet))")
            return
        }

        onFinish()
        #expect(finishCount == 1)
    }

    @Test
    func makeSheet_ShouldBuildNewMatch() {
        let sheet = AppSheet.newMatch {}
        #expect(String(describing: type(of: sut.makeSheet(sheet))).contains("NewMatchView<NewMatchViewModel>"))
        #expect(sheet.id == "newMatch")
    }

    @Test
    func makeSheet_ShouldBuildNewGame() {
        let sheet = AppSheet.newGame { _ in }
        #expect(String(describing: type(of: sut.makeSheet(sheet))).contains("NewGameView<NewGameViewModel>"))
        #expect(sheet.id == "newGame")
        #expect(sheet == .newGame { _ in })
        #expect((sheet == .newMatch {}) == false)
    }

    @Test
    func coordinator_ShouldActAsRouterForEveryFeature() {
        let coordinator: AppCoordinatorProtocol = sut
        coordinator.showNewMatch {}
        #expect(sut.sheet == .newMatch {})
        coordinator.closeNewMatch()
        #expect(sut.sheet == nil)
    }

    @Test
    func factory_ShouldBuildCoordinatorView() {
        #expect(AppCoordinatorFactory.build(coordinator: sut) is AppCoordinatorView)
    }
}

private extension AppCoordinatorTests {
    var rootDescription: String {
        String(describing: type(of: sut.makeRoot()))
    }
}
