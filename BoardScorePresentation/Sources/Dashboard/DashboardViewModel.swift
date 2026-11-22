//
//  DashboardViewModel.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import SwiftUI
import BoardScoreDomain

protocol DashboardViewModelProtocol: AnyObject, Observable {
    var state: DashboardViewModelState { get }
    func onAppear() async
    func onAddGameTapped()
}

enum DashboardViewModelState: Equatable {
    case idle
    case loading
    case content(contentData: ContentData)
    case empty
    case error

    var isContent: Bool {
        switch self {
        case .content: return true
        default: return false
        }
    }

    struct ContentData: Equatable {
        let gamesViewData: LastGamesView.ViewData
        let winnersViewData: TopWinnersView.ViewData
    }
}

@Observable
@MainActor
class DashboardViewModel {
    private let getLastGamesUseCase: GetLastGamesUseCaseProtocol
    private let getTopWinnersUseCase: GetTopWinnersUseCaseProtocol

    private let lastGamesMapper: LastGamesMapperProtocol
    private let topWinnersMapper: TopWinnersMapperProtocol

    private weak var router: DashboardRouting?

    private var reloadTask: Task<Void, Never>?

    var state: DashboardViewModelState = .idle

    init(
        getLastGamesUseCase: GetLastGamesUseCaseProtocol,
        getTopWinnersUseCase: GetTopWinnersUseCaseProtocol,
        lastGamesMapper: LastGamesMapperProtocol,
        topWinnersMapper: TopWinnersMapperProtocol,
        router: DashboardRouting?
    ) {
        self.getLastGamesUseCase = getLastGamesUseCase
        self.getTopWinnersUseCase = getTopWinnersUseCase
        self.lastGamesMapper = lastGamesMapper
        self.topWinnersMapper = topWinnersMapper
        self.router = router
    }
}

extension DashboardViewModel: DashboardViewModelProtocol {
    func onAppear() async {
        await load()
    }

    func onAddGameTapped() {
        router?.showNewMatch { [weak self] in
            self?.reload()
        }
    }
}

private extension DashboardViewModel {
    func reload() {
        reloadTask = Task { [weak self] in
            await self?.load()
            self?.reloadTask = nil
        }
    }

    func load() async {
        if !state.isContent {
            state = .loading
        }
        let getLastGamesUseCase = getLastGamesUseCase
        let getTopWinnersUseCase = getTopWinnersUseCase
        async let lastGamesResult = getLastGamesUseCase()
        async let topWinnersResult = getTopWinnersUseCase()
        do {
            let (games, winners) = try await (lastGamesResult, topWinnersResult)
            guard !Task.isCancelled else { return }

            guard !games.isEmpty else {
                state = .empty
                return
            }

            state = .content(
                contentData: DashboardViewModelState.ContentData(
                    gamesViewData: handleGames(games),
                    winnersViewData: handleWinners(winners)
                )
            )
        } catch {
            state = .error
        }
    }

    func handleGames(_ games: [Domain.GetLastGamesModel]?) -> LastGamesView.ViewData {
        lastGamesMapper.map(games)
    }

    func handleWinners(_ winners: [Domain.GetTopWinnersModel]?) -> TopWinnersView.ViewData {
        topWinnersMapper.map(winners)
    }
}
