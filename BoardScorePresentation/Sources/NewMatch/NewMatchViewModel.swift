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
    private let getPlayersUseCase: GetPlayersUseCaseProtocol
    private let addPlayerUseCase: AddPlayerUseCaseProtocol
    private let addMatchUseCase: AddMatchUseCaseProtocol
    private let resolveWinnersUseCase: ResolveWinnersUseCaseProtocol
    private let onFinish: @MainActor () -> Void

    private weak var router: NewMatchRouting?

    private var addPlayerTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?

    private(set) var games: [Domain.GameModel] = []
    private(set) var selectedGame: Domain.GameModel?
    private(set) var participants: [Domain.PlayerModel] = []
    private(set) var knownPlayers: [Domain.PlayerModel] = []
    private(set) var scores: [Domain.PlayerModel: [Domain.ScoreableModel: String]] = [:]
    private(set) var pendingGame: Domain.GameModel?
    private(set) var tiedPlayers: [Domain.PlayerModel] = []
    private(set) var isSaving = false

    var date: Date = .now
    var durationMinutes: Int?
    var showsAddPlayerError = false
    var showsSaveError = false

    init(
        getGamesUseCase: GetGamesUseCaseProtocol,
        getPlayersUseCase: GetPlayersUseCaseProtocol,
        addPlayerUseCase: AddPlayerUseCaseProtocol,
        addMatchUseCase: AddMatchUseCaseProtocol,
        resolveWinnersUseCase: ResolveWinnersUseCaseProtocol,
        router: NewMatchRouting?,
        onFinish: @escaping @MainActor () -> Void
    ) {
        self.getGamesUseCase = getGamesUseCase
        self.getPlayersUseCase = getPlayersUseCase
        self.addPlayerUseCase = addPlayerUseCase
        self.addMatchUseCase = addMatchUseCase
        self.resolveWinnersUseCase = resolveWinnersUseCase
        self.router = router
        self.onFinish = onFinish
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
        selectedGame != nil && participants.count >= Self.minimumPlayers && !isSaving
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

    func addNewGame() {
        router?.showNewGame { [weak self] game in
            self?.didCreate(game)
        }
    }

    func addExistingPlayer(_ player: Domain.PlayerModel) {
        guard !participants.contains(player) else { return }

        participants.append(player)
    }

    func addNewPlayer(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newPlayer = Domain.NewPlayerModel(name: trimmed)
        addPlayerTask = Task { [weak self] in
            await self?.add(newPlayer)
        }
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
    func add(_ newPlayer: Domain.NewPlayerModel) async {
        defer { addPlayerTask = nil }

        do {
            let player = try await addPlayerUseCase(newPlayer)
            knownPlayers.append(player)
            participants.append(player)
        } catch {
            showsAddPlayerError = true
        }
    }

    func didCreate(_ game: Domain.GameModel) {
        games.append(game)
        games.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        selectGame(game)
    }

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
            Domain.NewMatchModel.Participant(
                player: player,
                turnOrder: index,
                scores: Dictionary(uniqueKeysWithValues: game.scoreables.map {
                    ($0, value(for: player, scoreable: $0))
                }),
                isWinner: winners.contains(player)
            )
        }

        let match = Domain.NewMatchModel(
            game: game,
            playedAt: date,
            durationMinutes: durationMinutes,
            isWinnerManuallySelected: isManual,
            participants: participants
        )
        isSaving = true
        saveTask = Task { [weak self] in
            await self?.add(match)
        }
    }

    func add(_ match: Domain.NewMatchModel) async {
        defer {
            isSaving = false
            saveTask = nil
        }

        do {
            try await addMatchUseCase(match)
            router?.newMatchDidFinish()
            onFinish()
        } catch {
            showsSaveError = true
        }
    }
}
