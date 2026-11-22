//
//  NewGamePreviewDependencies.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 16/11/2026.
//

#if DEBUG

import Foundation
import BoardScoreDomain

@Observable
final class NewGameViewModelMock: NewGameViewModelProtocol {
    let scoreables: [Domain.ScoreableModel]
    let isDuplicateName: Bool

    var name: String
    var winCondition: Domain.WinCondition
    var showsSaveError = false

    var hasScoreables: Bool {
        !scoreables.isEmpty
    }

    var hasEmptyScoreables: Bool {
        scoreables.contains { $0.name.isEmpty }
    }

    var canSave: Bool {
        !name.isEmpty && !isDuplicateName && hasScoreables && !hasEmptyScoreables
    }

    init(
        name: String = "",
        winCondition: Domain.WinCondition = .highestScore,
        scoreables: [Domain.ScoreableModel] = [Domain.ScoreableModel(name: "")],
        isDuplicateName: Bool = false
    ) {
        self.name = name
        self.winCondition = winCondition
        self.scoreables = scoreables
        self.isDuplicateName = isDuplicateName
    }

    func onAppear() async {}
    func addScoreable() {}
    func renameScoreable(_ scoreable: Domain.ScoreableModel, to name: String) {}
    func removeScoreables(at offsets: IndexSet) {}
    func moveScoreables(from source: IndexSet, to destination: Int) {}
    func save() {}
    func cancel() {}
}

#endif
