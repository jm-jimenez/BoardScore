//
//  GameStatRowView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import SwiftUI

struct GameStatRowView: View {
    struct ViewData: Equatable {
        let title: String
        let value: String?
        let entries: [Entry]

        init(title: String, value: String) {
            self.title = title
            self.value = value
            self.entries = []
        }

        init(title: String, entries: [Entry]) {
            self.title = title
            self.value = nil
            self.entries = entries
        }

        struct Entry: Equatable {
            let player: String
            let value: String
            let note: String?
            let isSecondary: Bool

            init(player: String, value: String, note: String? = nil, isSecondary: Bool = false) {
                self.player = player
                self.value = value
                self.note = note
                self.isSecondary = isSecondary
            }
        }
    }

    enum C {
        static var spacing: CGFloat { 6 }
        static var secondaryIndent: CGFloat { 12 }
    }

    private let viewData: ViewData

    init(viewData: ViewData) {
        self.viewData = viewData
    }

    var body: some View {
        VStack(alignment: .leading, spacing: C.spacing) {
            HStack {
                Text(viewData.title)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                if let value = viewData.value {
                    Text(value)
                        .foregroundStyle(.secondary)
                }
            }
            ForEach(viewData.entries.enumerated(), id: \.offset) { _, entry in
                entryView(entry)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private extension GameStatRowView {
    func entryView(_ entry: ViewData.Entry) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading) {
                Text(entry.player)
                if let note = entry.note {
                    Text(note)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            Text(entry.value)
                .multilineTextAlignment(.trailing)
        }
        .font(entry.isSecondary ? .footnote : .subheadline)
        .foregroundStyle(.secondary)
        .padding(.leading, entry.isSecondary ? C.secondaryIndent : 0)
    }
}

#if DEBUG

#Preview("Value") {
    GameStatRowView(viewData: .init(title: "Times played", value: "20"))
        .padding()
}

#Preview("Tie") {
    GameStatRowView(
        viewData: .init(title: "Longest win streak", entries: [
            .init(player: "Mercedes", value: "4"),
            .init(player: "Dani", value: "4")
        ])
    )
    .padding()
}

#Preview("Secondary") {
    GameStatRowView(
        viewData: .init(title: "Best win rate", entries: [
            .init(player: "Mercedes", value: "75 % · 3 / 4"),
            .init(player: "Dani", value: "100 % · 1 / 1", note: "Only played 1 match", isSecondary: true)
        ])
    )
    .padding()
}

#endif
