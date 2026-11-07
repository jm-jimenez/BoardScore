//
//  SectionHeaderView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 24/10/2026.
//

import SwiftUI

struct SectionHeaderView: View {

    struct ViewData {
        let title: String
        let info: String
    }

    private let viewData: ViewData

    init(viewData: ViewData) {
        self.viewData = viewData
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(viewData.title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Text(viewData.info)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#if DEBUG

private extension SectionHeaderView.ViewData {
    static var mock: Self {
        Self(title: "Last games",
             info: "Winner")
    }
}

#Preview {
    SectionHeaderView(viewData: .mock)
}

#endif
