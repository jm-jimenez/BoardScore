//
//  NewMatchRouting.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import BoardScoreDomain

@MainActor
public protocol NewMatchRouting: AnyObject {
    func closeNewMatch()
    func newMatchDidFinish()
    func showNewGame(onCreate: @escaping @MainActor (Domain.GameModel) -> Void)
}
