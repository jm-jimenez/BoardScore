//
//  SideMenuView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import SwiftUI

struct SideMenuView: View {

    enum C {
        static var width: CGFloat { 280 }
        static var spacing: CGFloat { 4 }
        static var rowPadding: CGFloat { 12 }
        static var cornerRadius: CGFloat { 12 }
        static var selectedOpacity: Double { 0.15 }
        static var shadowOpacity: Double { 0.15 }
        static var shadowRadius: CGFloat { 16 }
    }

    @ScaledMetric private var iconWidth: CGFloat = 28

    let selectedSection: AppSection
    let onSelect: (AppSection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: C.spacing) {
            Text(verbatim: "BoardScore")
                .font(.largeTitle.bold())
                .padding(.horizontal, C.rowPadding)
                .padding(.vertical)
                .accessibilityAddTraits(.isHeader)
            ForEach(AppSection.allCases) { section in
                row(section)
            }
            Spacer()
        }
        .padding()
        .frame(width: C.width, alignment: .leading)
        .frame(maxHeight: .infinity)
        .background {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
                .shadow(color: .black.opacity(C.shadowOpacity), radius: C.shadowRadius)
        }
    }
}

private extension SideMenuView {
    func row(_ section: AppSection) -> some View {
        let isSelected = section == selectedSection
        return Button {
            onSelect(section)
        } label: {
            Label {
                Text(section.title)
            } icon: {
                Image(systemName: section.systemImage)
                    .frame(width: iconWidth)
            }
            .font(.headline)
            .foregroundStyle(isSelected ? Color.accentColor : .primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(C.rowPadding)
            .background {
                RoundedRectangle(cornerRadius: C.cornerRadius)
                    .fill(isSelected ? Color.accentColor.opacity(C.selectedOpacity) : .clear)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#if DEBUG

#Preview("Dashboard selected") {
    SideMenuView(selectedSection: .dashboard) { _ in }
}

#Preview("Players selected") {
    SideMenuView(selectedSection: .players) { _ in }
}

#endif
