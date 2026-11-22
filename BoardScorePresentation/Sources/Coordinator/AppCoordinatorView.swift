//
//  AppCoordinatorView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import SwiftUI

struct AppCoordinatorView: View {

    enum C {
        static var dimmingOpacity: Double { 0.3 }
        static var dismissDragThreshold: CGFloat { -60 }
    }

    @State private var coordinator: AppCoordinator

    init(coordinator: AppCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            NavigationStack(path: $coordinator.path) {
                coordinator.makeRoot()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            menuButton
                        }
                    }
            }
            .accessibilityHidden(coordinator.isSideMenuPresented)
            if coordinator.isSideMenuPresented {
                dimming
                sideMenu
            }
        }
        .animation(.snappy, value: coordinator.isSideMenuPresented)
        .sheet(item: $coordinator.sheet) { sheet in
            coordinator.makeSheet(sheet)
                .sheet(item: $coordinator.nestedSheet) { nestedSheet in
                    coordinator.makeSheet(nestedSheet)
                }
        }
    }
}

private extension AppCoordinatorView {
    var menuButton: some View {
        Button {
            coordinator.showSideMenu()
        } label: {
            Label("Menu".localized, systemImage: "line.3.horizontal")
        }
    }

    var dimming: some View {
        Color.black
            .opacity(C.dimmingOpacity)
            .ignoresSafeArea()
            .onTapGesture {
                coordinator.hideSideMenu()
            }
            .accessibilityHidden(true)
            .transition(.opacity)
    }

    var sideMenu: some View {
        SideMenuView(selectedSection: coordinator.section) { section in
            coordinator.select(section)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < C.dismissDragThreshold {
                        coordinator.hideSideMenu()
                    }
                }
        )
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape) {
            coordinator.hideSideMenu()
        }
        .transition(.move(edge: .leading))
    }
}
