//
//  NewGameFactoryTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 16/11/2026.
//

import Testing
@testable import BoardScorePresentation

struct NewGameFactoryTests {

    @MainActor @Test
    func newGameFactory_ShouldBuildView() {
        let view = NewGameFactory.build(dependencies: DashboardExternalDependenciesTest()) { _ in }
        #expect(view is NewGameView<NewGameViewModel>)
    }
}
