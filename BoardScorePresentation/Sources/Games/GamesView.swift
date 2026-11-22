//
//  GamesView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import SwiftUI
import BoardScoreDomain

struct GamesView<ViewModel>: View where ViewModel: GamesViewModelProtocol {

    enum C {
        static var spacing: CGFloat { 16 }
    }

    @State private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: C.spacing) {
                if !viewModel.games.isEmpty {
                    gamePicker
                }
                stateContent
            }
            .padding(.horizontal)
        }
        .scrollDisabled(viewModel.state == .noGames)
        .overlay {
            if viewModel.state == .noGames {
                noGames
            }
        }
        .background {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
        }
        .navigationTitle("Games".localized)
        .animation(.default, value: viewModel.state)
        .task {
            await viewModel.onAppear()
        }
    }
}

private extension GamesView {
    var selection: Binding<Domain.GameModel?> {
        Binding {
            viewModel.selectedGame
        } set: { game in
            guard let game else { return }

            viewModel.selectGame(game)
        }
    }

    var gamePicker: some View {
        LabeledContent("Game".localized) {
            Picker("Game".localized, selection: selection) {
                ForEach(viewModel.games) { game in
                    Text(game.name)
                        .tag(Optional(game))
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
        .dashboardCard()
    }

    @ViewBuilder
    var stateContent: some View {
        switch viewModel.state {
        case .content(let viewData):
            content(viewData)
        case .idle, .loading:
            content(.placeholder)
                .redacted(reason: .placeholder)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        case .notPlayed:
            unavailable(
                title: "This game hasn't been played yet".localized,
                systemImage: "dice",
                description: "Its statistics will show up after the first match".localized
            )
        case .error:
            unavailable(
                title: "Couldn't load the statistics".localized,
                systemImage: "exclamationmark.triangle",
                description: "Please try again.".localized
            )
        case .noGames:
            EmptyView()
        }
    }

    var noGames: some View {
        unavailable(
            title: "No games yet".localized,
            systemImage: "dice",
            description: "Games you add when creating a match will show up here".localized
        )
        .padding(.horizontal)
    }

    func content(_ viewData: GameStatsViewData) -> some View {
        VStack(spacing: C.spacing) {
            WinnersChartView(viewData: viewData.winners)
            GameStatsView(viewData: viewData.stats)
        }
    }

    func unavailable(title: String, systemImage: String, description: String) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(description)
        }
        .fixedSize(horizontal: false, vertical: true)
        .dashboardCard()
    }
}

#if DEBUG

#Preview("Content") {
    NavigationStack {
        GamesView(viewModel: GamesViewModelMock())
    }
}

#Preview("Loading") {
    NavigationStack {
        GamesView(viewModel: GamesViewModelMock(state: .loading))
    }
}

#Preview("No games") {
    NavigationStack {
        GamesView(viewModel: GamesViewModelMock(state: .noGames, games: []))
    }
}

#Preview("Not played") {
    NavigationStack {
        GamesView(viewModel: GamesViewModelMock(state: .notPlayed))
    }
}

#endif
