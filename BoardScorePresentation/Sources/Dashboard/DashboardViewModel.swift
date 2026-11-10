//
//  DashboardViewModel.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import SwiftUI
import BoardScoreDomain

protocol DashboardViewModelProtocol: ObservableObject {
    var state: DashboardViewModelState { get }
    func onAppear()
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
    private var onAppearTask: Task<Void, Never>?

    private let getLastGamesUseCase: GetLastGamesUseCaseProtocol
    private let getTopWinnersUseCase: GetTopWinnersUseCaseProtocol

    private let lastGamesMapper: LastGamesMapperProtocol
    private let topWinnersMapper: TopWinnersMapperProtocol

    var state: DashboardViewModelState = .idle

    init(
        getLastGamesUseCase: GetLastGamesUseCaseProtocol,
        getTopWinnersUseCase: GetTopWinnersUseCaseProtocol,
        lastGamesMapper: LastGamesMapperProtocol,
        topWinnersMapper: TopWinnersMapperProtocol
    ) {
        self.getLastGamesUseCase = getLastGamesUseCase
        self.getTopWinnersUseCase = getTopWinnersUseCase
        self.lastGamesMapper = lastGamesMapper
        self.topWinnersMapper = topWinnersMapper
    }
}

extension DashboardViewModel: DashboardViewModelProtocol {
    func onAppear() {
        guard onAppearTask == nil else { return }

        onAppearTask = Task { [weak self] in
            await self?.load()
        }
    }

    func onAddGameTapped() {}
}

private extension DashboardViewModel {
    func load() async {
        defer { onAppearTask = nil }
        state = .loading
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
