//
//  SectionItemView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 25/10/2026.
//

import SwiftUI

struct SectionItemView: View {
    struct ViewData {
        let description: String
        let info: String
        let value: String
    }

    private let viewData: ViewData

    init(viewData: ViewData) {
        self.viewData = viewData
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewData.description)
                    .font(.body)
                Text(viewData.info)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(viewData.value)
                .font(.callout)
                .foregroundStyle(Color.accentColor)
        }
    }
}

#if DEBUG

private extension SectionItemView.ViewData {
    static var mock: Self {
        Self(description: "Dominion",
             info: "4 mins ago",
             value: "Dani")
    }
}

#Preview {
    SectionItemView(viewData: .mock)
}

#endif
