//
//  Chart.swift
//  Chartzs
//
//  Created by José María Jiménez on 19/10/2026.
//

import SwiftUI

public enum Space: Sendable {
    case ratio(Double)
    case padding(Double)
    case none

    var hasInnerSpace: Bool {
        switch self {
        case .none: return false
        case .ratio(let value), .padding(let value):
            return value > 0
        }
    }
}

public struct Chartz: View {

    public struct ViewData {
        public static let defaultColors: [Color] = [
            .blue, .green, .orange, .purple, .pink, .teal, .yellow, .red, .indigo, .mint, .brown, .cyan
        ]

        let items: [Double]
        let colors: [Color]
        let spacing: CGFloat
        let innerRadius: Space
        let maxDiameter: CGFloat?
        let legend: Legend?

        public init(
            items: [Double],
            colors: [Color] = Self.defaultColors,
            spacing: CGFloat,
            innerRadius: Space,
            maxDiameter: CGFloat? = nil,
            legend: Legend? = nil
        ) {
            self.items = items
            self.colors = colors.isEmpty ? Self.defaultColors : colors
            self.spacing = spacing
            self.innerRadius = innerRadius
            self.maxDiameter = maxDiameter
            self.legend = legend
        }

        func color(at index: Int) -> Color {
            colors[index % colors.count]
        }
    }

    public struct Legend {
        public struct Item {
            let label: String
            let detail: String?

            public init(label: String, detail: String? = nil) {
                self.label = label
                self.detail = detail
            }
        }

        let items: [Item]
        let spacing: CGFloat

        public init(items: [Item], spacing: CGFloat = 12) {
            self.items = items
            self.spacing = spacing
        }
    }

    @Environment(\.redactionReasons) private var redactionReasons

    private let viewData: ViewData

    public init(viewData: ViewData) {
        self.viewData = viewData
    }

    public var body: some View {
        VStack(spacing: viewData.legend?.spacing ?? 0) {
            donut
            if let legend = viewData.legend {
                ChartzLegendView(legend: legend, viewData: viewData)
            }
        }
    }

    var isPlaceholder: Bool {
        redactionReasons.contains(.placeholder)
    }

    var donut: some View {
        ZStack {
            ForEach(segmentsViewData) { viewData in
                Segment(viewData: viewData)
                    .fill(viewData.color)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: viewData.maxDiameter, maxHeight: viewData.maxDiameter)
        .frame(maxWidth: .infinity)
        .grayscale(isPlaceholder ? 1 : 0)
        .opacity(isPlaceholder ? 0.3 : 1)
        .accessibilityHidden(true)
    }

    var segmentsViewData: [Segment.ViewData] {
        var startAngle = 0.0
        let spacing = viewData.items.count > 1 ? viewData.spacing : 0
        let reservedSpacing = CGFloat(viewData.items.count) * spacing
        let availableDegreess = 360.0 - reservedSpacing
        let eachSection = availableDegreess / viewData.items.reduce(0, +)
        var segments: [Segment.ViewData] = []
        viewData.items.enumerated().forEach { index, item in
            let endAngle = eachSection * item + startAngle
            segments.append(
                Segment.ViewData(
                    startAngle: startAngle,
                    endAngle: endAngle,
                    color: viewData.color(at: index),
                    innerRadius: viewData.innerRadius)
            )
            startAngle = endAngle + spacing
        }
        return segments
    }
}

#if DEBUG

private extension Chartz.ViewData {
    static var mock: Self {
        Self(items: [10, 20, 70],
             spacing: 12,
             innerRadius: .padding(12)
        )
    }

    static func mocked(
        items: [Double] = [10, 20, 70],
        spacing: CGFloat = 12,
        innerRadius: Space = .padding(12)
    ) -> Self {
        Self(items: items,
             spacing: spacing,
             innerRadius: innerRadius
        )
    }
}

#Preview {
    @Previewable @State var viewData: Chartz.ViewData = .mock

    VStack {
        Chartz(viewData: viewData)
            .background { Color.red }

        HStack {
            VStack(alignment: .leading) {
                Text("Spacing")
                Text("Inner radius")
            }
            VStack {
                Slider(value: Binding(
                    get: {
                        viewData.spacing
                    },
                    set: { newValue in
                        viewData = .mocked(items: viewData.items,
                                           spacing: newValue,
                                           innerRadius: viewData.innerRadius
                        )
                    }), in: 0...100)
                Slider(value: Binding(
                    get: {
                        guard case .padding(let double) = viewData.innerRadius else { return 0 }

                        return double
                    },
                    set: { newValue in
                        viewData = .mocked(items: viewData.items,
                                           spacing: viewData.spacing,
                                           innerRadius: .padding(newValue)
                        )
                    }), in: 0...100)
            }

        }
        .padding()

        Spacer()
    }
}

#Preview("Legend") {
    Chartz(
        viewData: Chartz.ViewData(
            items: [8, 6, 4, 2],
            spacing: 2,
            innerRadius: .ratio(0.6),
            maxDiameter: 180,
            legend: Chartz.Legend(items: [
                .init(label: "Mercedes", detail: "8 · 40 %"),
                .init(label: "Dani", detail: "6 · 30 %"),
                .init(label: "M@rio", detail: "4 · 20 %"),
                .init(label: "Lucía", detail: "2 · 10 %")
            ])
        )
    )
    .padding()
}

#endif
