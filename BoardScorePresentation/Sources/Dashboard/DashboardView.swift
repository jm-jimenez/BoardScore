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
    }

    @ObservedObject
    private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if case .content(let contentViewData) = viewModel.state {
                    content(contentViewData)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
            }
            .navigationTitle("Dashboard")
        }
        .onAppear {
            viewModel.onAppear()
        }
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

    func onAppear() {

    }
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

#endif
