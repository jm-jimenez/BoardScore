//
//  NewGameViewModel.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 16/11/2026.
//

import SwiftUI
import BoardScoreDomain

@Observable
@MainActor
final class NewGameViewModel {
    private let getGamesUseCase: GetGamesUseCaseProtocol
    private let addGameUseCase: AddGameUseCaseProtocol

    private weak var router: NewGameRouting?
    private let onCreate: @MainActor (Domain.GameModel) -> Void

    private var saveTask: Task<Void, Never>?

    private(set) var existingNames: [String] = []
    private(set) var scoreables: [Domain.ScoreableModel] = [Domain.ScoreableModel(name: "")]
    private(set) var isSaving = false

    var name = ""
    var winCondition: Domain.WinCondition = .highestScore
    var showsSaveError = false

    init(
        getGamesUseCase: GetGamesUseCaseProtocol,
        addGameUseCase: AddGameUseCaseProtocol,
        router: NewGameRouting?,
        onCreate: @escaping @MainActor (Domain.GameModel) -> Void
    ) {
        self.getGamesUseCase = getGamesUseCase
        self.addGameUseCase = addGameUseCase
        self.router = router
        self.onCreate = onCreate
    }
}

extension NewGameViewModel: NewGameViewModelProtocol {
    var isDuplicateName: Bool {
        guard !trimmedName.isEmpty else { return false }

        return existingNames.contains { existingName in
            let trimmedExistingName = existingName.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedExistingName.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }
    }

    var hasScoreables: Bool {
        !scoreables.isEmpty
    }

    var hasEmptyScoreables: Bool {
        scoreableNames.contains(where: \.isEmpty)
    }

    var canSave: Bool {
        !trimmedName.isEmpty && !isDuplicateName && hasScoreables && !hasEmptyScoreables && !isSaving
    }

    func onAppear() async {
        let games = (try? await getGamesUseCase()) ?? []
        existingNames = games.map(\.name)
    }

    func addScoreable() {
        scoreables.append(Domain.ScoreableModel(name: ""))
    }

    func renameScoreable(_ scoreable: Domain.ScoreableModel, to name: String) {
        guard let index = scoreables.firstIndex(where: { $0.id == scoreable.id }) else { return }

        scoreables[index] = Domain.ScoreableModel(id: scoreable.id, name: name)
    }

    func removeScoreables(at offsets: IndexSet) {
        scoreables.remove(atOffsets: offsets)
    }

    func moveScoreables(from source: IndexSet, to destination: Int) {
        scoreables.move(fromOffsets: source, toOffset: destination)
    }

    func save() {
        guard canSave else { return }

        isSaving = true
        let newGame = Domain.NewGameModel(
            name: trimmedName,
            winCondition: winCondition,
            scoreableNames: scoreableNames
        )
        saveTask = Task { [weak self] in
            await self?.add(newGame)
        }
    }

    func cancel() {
        router?.closeNewGame()
    }
}

private extension NewGameViewModel {
    func add(_ newGame: Domain.NewGameModel) async {
        defer {
            isSaving = false
            saveTask = nil
        }

        do {
            let game = try await addGameUseCase(newGame)
            router?.newGameDidFinish()
            onCreate(game)
        } catch {
            showsSaveError = true
        }
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var scoreableNames: [String] {
        scoreables.map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
}
