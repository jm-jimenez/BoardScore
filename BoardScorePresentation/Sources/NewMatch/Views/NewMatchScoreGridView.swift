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
        VStack(alignment: .leading, spacing: 0) {
            Color.clear
                .frame(height: C.rowHeight)
            ForEach(game.scoreables) { scoreable in
                Text(scoreable.name)
                    .lineLimit(1)
                    .frame(height: C.rowHeight)
            }
            Text("Total".localized)
                .bold()
                .frame(height: C.rowHeight)
        }
        .frame(width: C.labelColumnWidth, alignment: .leading)
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
