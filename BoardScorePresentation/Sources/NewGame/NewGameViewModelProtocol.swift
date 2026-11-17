//
//  NewGameViewModelProtocol.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 16/11/2026.
//

import Foundation
import BoardScoreDomain

@MainActor
protocol NewGameViewModelProtocol: AnyObject, Observable {
    var scoreables: [Domain.ScoreableModel] { get }
    var isDuplicateName: Bool { get }
    var hasScoreables: Bool { get }
    var hasEmptyScoreables: Bool { get }
    var canSave: Bool { get }

    var name: String { get set }
    var winCondition: Domain.WinCondition { get set }
    var showsSaveError: Bool { get set }

    func onAppear() async
    func addScoreable()
    func renameScoreable(_ scoreable: Domain.ScoreableModel, to name: String)
    func removeScoreables(at offsets: IndexSet)
    func moveScoreables(from source: IndexSet, to destination: Int)
    func save()
    func cancel()
}
