//
//  DashboardCardModifier.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 07/11/2026.
//

import SwiftUI

private enum DashboardCardConstants {
    static let cornerRadius: CGFloat = 20
}

extension View {
    func dashboardCard() -> some View {
        padding()
            .background(
                Color(uiColor: .secondarySystemGroupedBackground),
                in: .rect(cornerRadius: DashboardCardConstants.cornerRadius)
            )
    }
}
