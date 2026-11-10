//
//  String+Localized.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 10/11/2026.
//

import Foundation

extension String {
    var localized: String {
        String(localized: LocalizationValue(self), bundle: .module)
    }
}
