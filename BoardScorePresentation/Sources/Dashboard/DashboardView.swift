//
//  DashboardView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import SwiftUI

struct DashboardView<ViewModel>: View where ViewModel: DashboardViewModelProtocol {

    enum C {
        static var chartHeight: CGFloat { 200 }
        static var spacing: CGFloat { 16 }
        static var emptySkeletonOpacity: Double { 0.4 }
        static var emptyShadowOpacity: Double { 0.12 }
        static var emptyShadowRadius: CGFloat { 24 }
        static var emptyShadowOffset: CGFloat { 8 }
    }

    @ObservedObject
    private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                switch viewModel.state {
                case .content(let contentViewData):
                    content(contentViewData)
                default:
                    skeleton
                }
            }
            .scrollDisabled(!viewModel.state.isContent)
            .overlay {
                if viewModel.state == .empty {
                    emptyState
                }
            }
            .background {
                Self.background
                    .ignoresSafeArea()
            }
            .navigationTitle("Dashboard".localized)
            .animation(.default, value: viewModel.state)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    var skeleton: some View {
        content(.placeholder)
            .redacted(reason: .placeholder)
            .opacity(viewModel.state == .empty ? C.emptySkeletonOpacity : 1)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text("No games played yet".localized)
            } icon: {
                Image(systemName: "dice")
            }
        } description: {
            Text("Add your first game".localized)
        } actions: {
            Button {
                viewModel.onAddGameTapped()
            } label: {
                Label {
                    Text("Add game".localized)
                } icon: {
                    Image(systemName: "plus")
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .fixedSize(horizontal: false, vertical: true)
        .dashboardCard()
        .compositingGroup()
        .shadow(
            color: .black.opacity(C.emptyShadowOpacity),
            radius: C.emptyShadowRadius,
            y: C.emptyShadowOffset
        )
        .padding(.horizontal)
    }

    static var background: Color {
        Color(uiColor: .systemGroupedBackground)
    }

    func content(_ contentViewData: DashboardViewModelState.ContentData) -> some View {
        VStack(spacing: C.spacing) {
            ChartView()
                .frame(height: C.chartHeight)
                .frame(maxWidth: .infinity)
                .dashboardCard()
            LastGamesView(viewData: contentViewData.gamesViewData)
            TopWinnersView(viewData: contentViewData.winnersViewData)
        }
        .padding(.horizontal)
    }
}

#if DEBUG

private class DashboardViewModelMock: DashboardViewModelProtocol {
    let state: DashboardViewModelState

    init(state: DashboardViewModelState = .content(contentData: .mock)) {
        self.state = state
    }

    func onAppear() {}

    func onAddGameTapped() {}
}

private extension DashboardViewModelState.ContentData {
    static var mock: Self {
        Self(
            gamesViewData: LastGamesView.ViewData(items: [
                LastGamesView.ViewData.LastGame(
                    name: "Dominion",
                    winner: "Dani",
                    date: "4 mins ago"
                ),
                LastGamesView.ViewData.LastGame(
                    name: "Pociones",
                    winner: "Mercedes",
                    date: "5 days ago"
                )
            ]),
            winnersViewData: TopWinnersView.ViewData(items: [
                TopWinnersView.ViewData.WinnerSummary(
                    name: "Mercedes",
                    lastGame: "Wingspan",
                    winsLosses: "13 / 6"
                ),
                TopWinnersView.ViewData.WinnerSummary(
                    name: "M@rio",
                    lastGame: "Alquimistas",
                    winsLosses: "8 / 3"
                )
            ])
        )
    }
}

#Preview("Content") {
    DashboardView(viewModel: DashboardViewModelMock())
}

#Preview("Loading") {
    DashboardView(viewModel: DashboardViewModelMock(state: .loading))
}

#Preview("Empty") {
    DashboardView(viewModel: DashboardViewModelMock(state: .empty))
}

#endif
