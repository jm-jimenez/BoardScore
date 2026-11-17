//
//  NewMatchViewModelProtocol.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation
import BoardScoreDomain

@MainActor
protocol NewMatchViewModelProtocol: AnyObject, Observable {
    static var minimumPlayers: Int { get }

    var games: [Domain.GameModel] { get }
    var selectedGame: Domain.GameModel? { get }
    var participants: [Domain.PlayerModel] { get }
    var availablePlayers: [Domain.PlayerModel] { get }
    var pendingGame: Domain.GameModel? { get }
    var tiedPlayers: [Domain.PlayerModel] { get }
    var leaders: Set<Domain.PlayerModel> { get }
    var canSave: Bool { get }

    var date: Date { get set }
    var durationMinutes: Int? { get set }
    var hasDuration: Bool { get set }
    var showsAddPlayerError: Bool { get set }

    func onAppear() async
    func total(for player: Domain.PlayerModel) -> Int
    func score(for player: Domain.PlayerModel, scoreable: Domain.ScoreableModel) -> String
    func canMove(_ player: Domain.PlayerModel, direction: NewMatchMoveDirection) -> Bool

    func selectGame(_ game: Domain.GameModel)
    func confirmGameChange(_ game: Domain.GameModel)
    func cancelGameChange()
    func addNewGame()
    func addExistingPlayer(_ player: Domain.PlayerModel)
    func addNewPlayer(name: String)
    func removePlayer(_ player: Domain.PlayerModel)
    func movePlayer(_ player: Domain.PlayerModel, direction: NewMatchMoveDirection)
    func updateScore(_ text: String, for player: Domain.PlayerModel, scoreable: Domain.ScoreableModel)
    func save()
    func selectTieWinner(_ player: Domain.PlayerModel)
    func cancelTie()
    func cancel()
}
