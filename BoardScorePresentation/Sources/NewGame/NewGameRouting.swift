//
//  NewGameRouting.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 16/11/2026.
//

@MainActor
public protocol NewGameRouting: AnyObject {
    func closeNewGame()
    func newGameDidFinish()
}
