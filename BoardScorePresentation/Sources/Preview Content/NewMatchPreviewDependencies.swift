//
//  NewMatchPreviewDependencies.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

#if DEBUG

import Foundation
import BoardScoreDomain

@Observable
final class NewMatchViewModelMock: NewMatchViewModelProtocol {
    static let minimumPlayers = 2

    let games: [Domain.GameModel]
    let selectedGame: Domain.GameModel?
    let participants: [Domain.PlayerModel]
    let availablePlayers: [Domain.PlayerModel]
    let pendingGame: Domain.GameModel? = nil
    let tiedPlayers: [Domain.PlayerModel] = []
    let leaders: Set<Domain.PlayerModel>
    let canSave: Bool

    var date = Date()
    var durationMinutes: Int?
    var showsAddPlayerError = false
    var showsSaveError = false
    var hasDuration: Bool {
        get { durationMinutes != nil }
        set { durationMinutes = newValue ? 60 : nil }
    }

    private let scores: [Domain.PlayerModel: [Domain.ScoreableModel: String]]

    init(
        games: [Domain.GameModel] = [.previewWingspan],
        selectedGame: Domain.GameModel? = .previewWingspan,
        participants: [Domain.PlayerModel] = Domain.PlayerModel.previewPlayers,
        availablePlayers: [Domain.PlayerModel] = [Domain.PlayerModel(name: "Lucía")],
        scores: [Domain.PlayerModel: [Domain.ScoreableModel: String]] = .previewScores,
        durationMinutes: Int? = 45
    ) {
        self.games = games
        self.selectedGame = selectedGame
        self.participants = participants
        self.availablePlayers = availablePlayers
        self.scores = scores
        self.durationMinutes = durationMinutes
        let totals = participants.map { player in
            (player, scores[player, default: [:]].values.compactMap { Int($0) }.reduce(0, +))
        }
        let best = totals.map(\.1).max()
        leaders = Set(totals.filter { $0.1 == best }.map(\.0))
        canSave = selectedGame != nil && participants.count >= Self.minimumPlayers
    }

    func onAppear() async {}

    func total(for player: Domain.PlayerModel) -> Int {
        scores[player, default: [:]].values.compactMap { Int($0) }.reduce(0, +)
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

    func selectGame(_ game: Domain.GameModel) {}
    func confirmGameChange(_ game: Domain.GameModel) {}
    func cancelGameChange() {}
    func addNewGame() {}
    func addExistingPlayer(_ player: Domain.PlayerModel) {}
    func addNewPlayer(name: String) {}
    func removePlayer(_ player: Domain.PlayerModel) {}
    func movePlayer(_ player: Domain.PlayerModel, direction: NewMatchMoveDirection) {}
    func updateScore(_ text: String, for player: Domain.PlayerModel, scoreable: Domain.ScoreableModel) {}
    func save() {}
    func selectTieWinner(_ player: Domain.PlayerModel) {}
    func cancelTie() {}
    func cancel() {}
}

extension Domain.GameModel {
    static let previewWingspan = Domain.GameModel(
        name: "Wingspan",
        winCondition: .highestScore,
        scoreables: ["Birds", "Bonus", "Eggs", "Food", "Tucked"].map {
            Domain.ScoreableModel(name: $0)
        }
    )
}

extension Domain.PlayerModel {
    static let previewPlayers = ["Mercedes", "Dani", "M@rio"].map { Domain.PlayerModel(name: $0) }
}

extension [Domain.PlayerModel: [Domain.ScoreableModel: String]] {
    static var previewScores: Self {
        let points = [["32", "7", "12", "4", "6"], ["28", "10", "9", "5", "3"], ["35", "4", "8", "", "-2"]]
        let scoreables = Domain.GameModel.previewWingspan.scoreables
        var scores: Self = [:]
        for (player, values) in zip(Domain.PlayerModel.previewPlayers, points) {
            scores[player] = [Domain.ScoreableModel: String](uniqueKeysWithValues: zip(scoreables, values))
        }
        return scores
    }
}

#endif
