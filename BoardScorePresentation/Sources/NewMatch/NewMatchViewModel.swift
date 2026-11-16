//
//  NewMatchViewModel.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation
import BoardScoreDomain

@Observable
@MainActor
final class NewMatchViewModel {
    static let minimumPlayers = 2
    static let defaultDurationMinutes = 60

    private let getGamesUseCase: GetGamesUseCaseProtocol
    private let addGameUseCase: AddGameUseCaseProtocol
    private let getPlayersUseCase: GetPlayersUseCaseProtocol
    private let resolveWinnersUseCase: ResolveWinnersUseCaseProtocol

    private weak var router: NewMatchRouting?

    private(set) var games: [Domain.GameModel] = []
    private(set) var selectedGame: Domain.GameModel?
    private(set) var participants: [Domain.PlayerModel] = []
    private(set) var knownPlayers: [Domain.PlayerModel] = []
    private(set) var scores: [Domain.PlayerModel: [Domain.ScoreableModel: String]] = [:]
    private(set) var pendingGame: Domain.GameModel?
    private(set) var tiedPlayers: [Domain.PlayerModel] = []
    private(set) var result: NewMatchResult?

    var date: Date = .now
    var durationMinutes: Int?

    init(
        getGamesUseCase: GetGamesUseCaseProtocol,
        addGameUseCase: AddGameUseCaseProtocol,
        getPlayersUseCase: GetPlayersUseCaseProtocol,
        resolveWinnersUseCase: ResolveWinnersUseCaseProtocol,
        router: NewMatchRouting?
    ) {
        self.getGamesUseCase = getGamesUseCase
        self.addGameUseCase = addGameUseCase
        self.getPlayersUseCase = getPlayersUseCase
        self.resolveWinnersUseCase = resolveWinnersUseCase
        self.router = router
    }
}

extension NewMatchViewModel: NewMatchViewModelProtocol {
    var availablePlayers: [Domain.PlayerModel] {
        knownPlayers.filter { !participants.contains($0) }
    }

    var hasDuration: Bool {
        get { durationMinutes != nil }
        set { durationMinutes = newValue ? (durationMinutes ?? Self.defaultDurationMinutes) : nil }
    }

    var leaders: Set<Domain.PlayerModel> {
        guard let selectedGame, hasScores else { return [] }

        return resolveWinners(in: selectedGame)
    }

    var canSave: Bool {
        selectedGame != nil && participants.count >= Self.minimumPlayers
    }

    func onAppear() async {
        let getGamesUseCase = getGamesUseCase
        let getPlayersUseCase = getPlayersUseCase
        async let games = try? getGamesUseCase()
        async let players = try? getPlayersUseCase()
        let (loadedGames, loadedPlayers) = await (games, players)

        self.games = loadedGames ?? []
        knownPlayers = loadedPlayers ?? []
    }

    func total(for player: Domain.PlayerModel) -> Int {
        guard let selectedGame else { return 0 }

        return selectedGame.scoreables.reduce(0) { sum, scoreable in
            sum + value(for: player, scoreable: scoreable)
        }
    }

    func score(for player: Domain.PlayerModel, scoreable: Domain.ScoreableModel) -> String {
        scores[player]?[scoreable] ?? ""
    }

    func canMove(_ player: Domain.PlayerModel, direction: NewMatchMoveDirection) -> Bool {
        guard let index = participants.firstIndex(of: player) else { return false }

        switch direction {
        case .left: return index > participants.startIndex
        case .right: return index < participants.index(before: participants.endIndex)
        }
    }

    func selectGame(_ game: Domain.GameModel) {
        guard game != selectedGame else { return }

        guard hasScores else {
            apply(game)
            return
        }

        pendingGame = game
    }

    func confirmGameChange(_ game: Domain.GameModel) {
        pendingGame = nil
        apply(game)
    }

    func cancelGameChange() {
        pendingGame = nil
    }

    func addMockGame() async {
        let newGame = NewMatchMockGameFactory.make(number: games.count + 1)
        guard let game = try? await addGameUseCase(newGame) else { return }

        games.append(game)
        games.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        selectGame(game)
    }

    func addExistingPlayer(_ player: Domain.PlayerModel) {
        guard !participants.contains(player) else { return }

        participants.append(player)
    }

    func addNewPlayer(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let player = Domain.PlayerModel(name: trimmed)
        knownPlayers.append(player)
        participants.append(player)
    }

    func removePlayer(_ player: Domain.PlayerModel) {
        participants.removeAll { $0 == player }
        scores[player] = nil
    }

    func movePlayer(_ player: Domain.PlayerModel, direction: NewMatchMoveDirection) {
        guard canMove(player, direction: direction),
              let index = participants.firstIndex(of: player) else { return }

        let destination = direction == .left ? index - 1 : index + 1
        participants.swapAt(index, destination)
    }

    func updateScore(_ text: String, for player: Domain.PlayerModel, scoreable: Domain.ScoreableModel) {
        scores[player, default: [:]][scoreable] = text
    }

    func save() {
        guard canSave, let selectedGame else { return }

        let winners = resolveWinners(in: selectedGame)
        guard winners.count <= 1 else {
            tiedPlayers = participants.filter { winners.contains($0) }
            return
        }

        finish(game: selectedGame, winners: winners, isManual: false)
    }

    func selectTieWinner(_ player: Domain.PlayerModel) {
        tiedPlayers = []
        guard let selectedGame else { return }

        finish(game: selectedGame, winners: [player], isManual: true)
    }

    func cancelTie() {
        tiedPlayers = []
    }

    func cancel() {
        router?.closeNewMatch()
    }
}

extension NewMatchViewModel {
    var hasScores: Bool {
        scores.values.contains { row in
            row.values.contains { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        }
    }

    var totals: [Domain.PlayerModel: Int] {
        Dictionary(uniqueKeysWithValues: participants.map { ($0, total(for: $0)) })
    }
}

private extension NewMatchViewModel {
    func resolveWinners(in game: Domain.GameModel) -> Set<Domain.PlayerModel> {
        resolveWinnersUseCase(totals: totals, winCondition: game.winCondition)
    }

    func apply(_ game: Domain.GameModel) {
        selectedGame = game
        scores = [:]
    }

    func value(for player: Domain.PlayerModel, scoreable: Domain.ScoreableModel) -> Int {
        Int(score(for: player, scoreable: scoreable).trimmingCharacters(in: .whitespaces)) ?? 0
    }

    func finish(game: Domain.GameModel, winners: Set<Domain.PlayerModel>, isManual: Bool) {
        let participants = participants.enumerated().map { index, player in
            NewMatchResult.Participant(
                player: player,
                turnOrder: index,
                scores: Dictionary(uniqueKeysWithValues: game.scoreables.map {
                    ($0, value(for: player, scoreable: $0))
                }),
                total: total(for: player),
                isWinner: winners.contains(player)
            )
        }

        let result = NewMatchResult(
            game: game,
            date: date,
            durationMinutes: durationMinutes,
            isWinnerManuallySelected: isManual,
            participants: participants
        )
        self.result = result
        router?.newMatchDidFinish()
    }
}
