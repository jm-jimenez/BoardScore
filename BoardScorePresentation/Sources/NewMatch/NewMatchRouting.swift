//
//  NewMatchRouting.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

@MainActor
public protocol NewMatchRouting: AnyObject {
    func closeNewMatch()
    func newMatchDidFinish()
}
