//
//  NewMatchScoreGridView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import SwiftUI
import BoardScoreDomain

struct NewMatchScoreGridView<ViewModel>: View where ViewModel: NewMatchViewModelProtocol {

    enum C {
        static var rowHeight: CGFloat { 44 }
        static var labelColumnWidth: CGFloat { 110 }
        static var playerColumnWidth: CGFloat { 84 }
        static var spacing: CGFloat { 8 }
        static var fieldCornerRadius: CGFloat { 8 }
    }

    @State private var labelsScrollPhase: ScrollPhase = .idle
    @State private var isLabelsScrolledAway = false
    @State private var isLabelsOverflowing = false

    private let viewModel: ViewModel
    private let game: Domain.GameModel

    init(viewModel: ViewModel, game: Domain.GameModel) {
        self.viewModel = viewModel
        self.game = game
    }

    var body: some View {
        HStack(alignment: .top, spacing: C.spacing) {
            labelsColumn
            ScrollView(.horizontal) {
                Grid(horizontalSpacing: C.spacing, verticalSpacing: 0) {
                    GridRow {
                        ForEach(viewModel.participants) { player in
                            header(for: player)
                        }
                    }
                    ForEach(game.scoreables) { scoreable in
                        GridRow {
                            ForEach(viewModel.participants) { player in
                                scoreField(for: player, scoreable: scoreable)
                            }
                        }
                    }
                    GridRow {
                        ForEach(viewModel.participants) { player in
                            totalCell(for: player)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    var labelsColumn: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 0) {
                Color.clear
                    .frame(height: C.rowHeight)
                ForEach(game.scoreables) { scoreable in
                    label(Text(scoreable.name))
                }
                label(Text("Total".localized).bold())
            }
            .animation(.easeInOut(duration: 0.15), value: isShowingFullLabels)
        }
        .scrollIndicators(isLabelsOverflowing ? .visible : .hidden)
        .scrollIndicatorsFlash(trigger: isLabelsOverflowing)
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentSize.width > geometry.containerSize.width
        } action: { _, isOverflowing in
            isLabelsOverflowing = isOverflowing
        }
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.x + geometry.contentInsets.leading > 0
        } action: { _, isScrolledAway in
            isLabelsScrolledAway = isScrolledAway
        }
        .onScrollPhaseChange { _, phase in
            labelsScrollPhase = phase
        }
        .frame(width: C.labelColumnWidth, alignment: .leading)
    }

    var isShowingFullLabels: Bool {
        labelsScrollPhase.isScrolling || isLabelsScrolledAway
    }

    func label(_ text: Text) -> some View {
        ZStack(alignment: .leading) {
            text
                .lineLimit(1)
                .fixedSize()
                .opacity(isShowingFullLabels ? 1 : 0)
                .accessibilityHidden(true)
            text
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: C.labelColumnWidth, alignment: .leading)
                .opacity(isShowingFullLabels ? 0 : 1)
        }
        .frame(height: C.rowHeight)
    }

    func header(for player: Domain.PlayerModel) -> some View {
        cell {
            Menu {
                Button {
                    viewModel.movePlayer(player, direction: .left)
                } label: {
                    Label("Move left".localized, systemImage: "arrow.left")
                }
                .disabled(!viewModel.canMove(player, direction: .left))
                Button {
                    viewModel.movePlayer(player, direction: .right)
                } label: {
                    Label("Move right".localized, systemImage: "arrow.right")
                }
                .disabled(!viewModel.canMove(player, direction: .right))
                Divider()
                Button(role: .destructive) {
                    viewModel.removePlayer(player)
                } label: {
                    Label("Remove".localized, systemImage: "trash")
                }
            } label: {
                Text(player.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
        }
    }

    func scoreField(for player: Domain.PlayerModel, scoreable: Domain.ScoreableModel) -> some View {
        cell {
            TextField("0", text: scoreBinding(player: player, scoreable: scoreable))
                .keyboardType(.numbersAndPunctuation)
                .multilineTextAlignment(.center)
                .monospacedDigit()
                .padding(.vertical, 6)
                .background(Color(uiColor: .tertiarySystemFill), in: .rect(cornerRadius: C.fieldCornerRadius))
                .accessibilityLabel("\(player.name), \(scoreable.name)")
        }
    }

    func totalCell(for player: Domain.PlayerModel) -> some View {
        cell {
            HStack(spacing: 4) {
                if viewModel.leaders.contains(player) {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                        .imageScale(.small)
                }
                Text(viewModel.total(for: player), format: .number)
                    .bold()
                    .monospacedDigit()
            }
        }
    }

    func cell<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(width: C.playerColumnWidth, height: C.rowHeight)
    }

    func scoreBinding(player: Domain.PlayerModel, scoreable: Domain.ScoreableModel) -> Binding<String> {
        Binding {
            viewModel.score(for: player, scoreable: scoreable)
        } set: { text in
            viewModel.updateScore(text, for: player, scoreable: scoreable)
        }
    }
}
