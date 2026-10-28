//
//  DashboardViewModel.swift
//  BoarsScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import SwiftUI
import BoardScoreDomain

protocol DashboardViewModelProtocol: ObservableObject {
    var state: DashboardViewModelState { get }
    func onAppear()
}

enum DashboardViewModelState {
    case idle
    case loading
    case content(contentData: ContentData)
    case error

    struct ContentData {
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
        getLastGamesUseCase: GetLastGamesUseCaseProtocol = GetLastGamesUseCase(),
        getTopWinnersUseCase: GetTopWinnersUseCaseProtocol = GetTopWinnersUseCase(),
        lastGamesMapper: LastGamesMapperProtocol = LastGamesMapper(),
        topWinnersMapper: TopWinnersMapperProtocol = TopWinnersMapper()
    ) {
        self.getLastGamesUseCase = getLastGamesUseCase
        self.getTopWinnersUseCase = getTopWinnersUseCase
        self.lastGamesMapper = lastGamesMapper
        self.topWinnersMapper = topWinnersMapper
    }
}

extension DashboardViewModel: DashboardViewModelProtocol {
    func onAppear() {
        onAppearTask?.cancel()
        onAppearTask = Task { [weak self] in
            self?.state = .loading
            async let lastGamesResult = self?.getLastGamesUseCase()
            async let topWinnersResult = self?.getTopWinnersUseCase()
            do {
                let (games, winners) = try await (lastGamesResult, topWinnersResult)
                guard !Task.isCancelled,
                      let self else { return }
                let gamesViewData = self.handleGames(games)
                let winnersViewData = self.handleWinners(winners)

                self.state = .content(
                    contentData: DashboardViewModelState.ContentData(
                        gamesViewData: gamesViewData,
                        winnersViewData: winnersViewData
                    )
                )

                onAppearTask = nil
            } catch {
                self?.state = .error
            }
        }
    }
}

private extension DashboardViewModel {
    func handleGames(_ games: [Domain.GetLastGamesModel]?) -> LastGamesView.ViewData {
        lastGamesMapper.map(games)
    }

    func handleWinners(_ winners: [Domain.GetTopWinnersModel]?) -> TopWinnersView.ViewData {
        topWinnersMapper.map(winners)
    }
}
