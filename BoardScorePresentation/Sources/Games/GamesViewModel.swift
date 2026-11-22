//
//  GamesViewModel.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import SwiftUI
import BoardScoreDomain

@Observable
@MainActor
final class GamesViewModel {
    private let getGamesUseCase: GetGamesUseCaseProtocol
    private let getGameStatsUseCase: GetGameStatsUseCaseProtocol
    private let statsMapper: GameStatsMapperProtocol

    private var statsTask: Task<Void, Never>?

    private(set) var state: GamesViewModelState = .idle
    private(set) var games: [Domain.GameModel] = []
    private(set) var selectedGame: Domain.GameModel?

    init(
        getGamesUseCase: GetGamesUseCaseProtocol,
        getGameStatsUseCase: GetGameStatsUseCaseProtocol,
        statsMapper: GameStatsMapperProtocol
    ) {
        self.getGamesUseCase = getGamesUseCase
        self.getGameStatsUseCase = getGameStatsUseCase
        self.statsMapper = statsMapper
    }
}

extension GamesViewModel: GamesViewModelProtocol {
    func onAppear() async {
        if !state.isContent {
            state = .loading
        }

        do {
            games = try await getGamesUseCase()
        } catch {
            state = .error
            return
        }

        guard let game = games.first(where: { $0.id == selectedGame?.id }) ?? games.first else {
            selectedGame = nil
            state = .noGames
            return
        }

        selectedGame = game
        await loadStats(for: game)
    }

    func selectGame(_ game: Domain.GameModel) {
        guard game != selectedGame else { return }

        selectedGame = game
        state = .loading
        statsTask?.cancel()
        statsTask = Task { [weak self] in
            await self?.loadStats(for: game)
        }
    }
}

private extension GamesViewModel {
    func loadStats(for game: Domain.GameModel) async {
        let result: GamesViewModelState
        do {
            let stats = try await getGameStatsUseCase(game: game)
            result = stats.timesPlayed == 0 ? .notPlayed : .content(statsMapper.map(stats))
        } catch {
            result = .error
        }

        guard !Task.isCancelled, game == selectedGame else { return }

        state = result
    }
}
