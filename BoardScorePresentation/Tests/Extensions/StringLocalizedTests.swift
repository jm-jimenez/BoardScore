//
//  StringLocalizedTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 10/11/2026.
//

import Testing
@testable import BoardScorePresentation

struct StringLocalizedTests {

    @Test
    func localized_WhenKeyExists_ShouldReturnTranslation() {
        #expect(["Add game", "Añadir partida"].contains("Add game".localized))
    }

    @Test
    func localized_WhenKeyIsMissing_ShouldReturnKey() {
        #expect("missing.key".localized == "missing.key")
    }
}
