//
//  Segment.swift
//  Chartzs
//
//  Created by José María Jiménez on 19/10/2026.
//

import SwiftUI

struct Segment: Shape {
    struct ViewData: Identifiable {
        let id: UUID
        let startAngle: Double
        let endAngle: Double
        let color: Color
        let innerRadius: Space

        init(startAngle: Double,
             endAngle: Double,
             color: Color,
             innerRadius: Space = .none) {
            self.id = UUID()
            self.startAngle = startAngle
            self.endAngle = endAngle
            self.color = color
            self.innerRadius = innerRadius
        }
    }

    private let viewData: ViewData

    init(viewData: ViewData) {
        self.viewData = viewData
    }

    func path(in rect: CGRect) -> Path {
        let center = rect.midX
        let centerPoint = CGPoint(x: center, y: center)
        var path = Path()
        path.move(to: centerPoint)
        path.addArc(
            center: centerPoint,
            radius: center,
            startAngle: Angle(degrees: viewData.startAngle - 90),
            endAngle: Angle(degrees: viewData.endAngle - 90),
            clockwise: false)

        if viewData.innerRadius.hasInnerSpace {
            path.addArc(
                center: centerPoint,
                radius: getInnerRadius(in: rect),
                startAngle: Angle(degrees: viewData.endAngle - 90),
                endAngle: Angle(degrees: viewData.startAngle - 90),
                clockwise: true)
        }
        path.closeSubpath()
        return path
    }

    func getInnerRadius(in rect: CGRect) -> CGFloat {
        let maxRadius = rect.midX
        switch viewData.innerRadius {
        case .ratio(let ratio):
            return maxRadius * min(ratio, 1)
        case .padding(let value):
            return min(maxRadius, CGFloat(value))
        case .none:
            return 0
        }
    }
}

#if DEBUG


extension Segment.ViewData {
    static var mock: Self {
        Self(startAngle: 0,
             endAngle: 90,
             color: .blue
        )
    }

    static func mocked(
        startAngle: Double = 0,
        endAngle: Double = 0,
        color: Color = .blue,
        innerRadius: Space = .none
    ) -> Self {
        Self(startAngle: startAngle,
             endAngle: endAngle,
             color: color,
             innerRadius: innerRadius
        )
    }
}

#Preview {
    @Previewable @State var viewData: Segment.ViewData = .mock

    VStack {
        HStack {
            Text("Star angle")
            Spacer()
            Slider(value: Binding(
                get: {
                    viewData.startAngle
                },
                set: { newValue in
                    viewData = .mocked(startAngle: newValue,
                                       endAngle: viewData.endAngle,
                                       color: viewData.color,
                                       innerRadius: viewData.innerRadius
                    )
                }), in: 0...360)
        }

        HStack {
            Text("End angle")
            Spacer()
            Slider(value: Binding(
                get: {
                    viewData.endAngle
                },
                set: { newValue in
                    viewData = .mocked(startAngle: viewData.startAngle,
                                       endAngle: newValue,
                                       color: viewData.color,
                                       innerRadius: viewData.innerRadius
                    )
                }), in: 0...360)
        }

        HStack {
            Text("Inner radius")
            Spacer()
            Slider(value: Binding(
                get: {
                    guard case .ratio(let double) = viewData.innerRadius else {
                        return 0
                    }
                    return double * 100
                },
                set: { newValue in
                    viewData = .mocked(startAngle: viewData.startAngle,
                                       endAngle: viewData.endAngle,
                                       color: viewData.color,
                                       innerRadius: .ratio(newValue / 100)
                    )
                }),
                   in: 0...100,
                   step: 1
            )
        }

        Segment(viewData: viewData)
            .background {Color.red}
            .padding(.top)

        Spacer()
    }
}

#endif
