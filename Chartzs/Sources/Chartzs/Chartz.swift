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
        let items: [Double]
        let spacing: CGFloat
        let innerRadius: Space

        public init(items: [Double],
             spacing: CGFloat,
             innerRadius: Space
        ) {
            self.items = items
            self.spacing = spacing
            self.innerRadius = innerRadius
        }
    }

    public init(viewData: ViewData) {
        self.viewData = viewData
    }

    private let viewData: ViewData

    public var body: some View {
        ZStack {
            ForEach(segmentsViewData) { viewData in
                Segment(viewData: viewData)
                    .fill(viewData.color)
            }
        }
        .aspectRatio(contentMode: .fit)
    }

    var colors: [Color] {
        [.blue, .green, .orange]
    }

    var segmentsViewData: [Segment.ViewData] {
        var startAngle = 0.0
        let reservedSpacing = CGFloat(viewData.items.count) * viewData.spacing
        let availableDegreess = 360.0 - reservedSpacing
        let eachSection = availableDegreess / viewData.items.reduce(0, +)
        var segments: [Segment.ViewData] = []
        viewData.items.enumerated().forEach { index, item in
            let endAngle = eachSection * item + startAngle
            segments.append(
                Segment.ViewData(
                    startAngle: startAngle,
                    endAngle: endAngle,
                    color: colors[index],
                    innerRadius: viewData.innerRadius)
            )
            startAngle = endAngle + viewData.spacing
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

#endif
