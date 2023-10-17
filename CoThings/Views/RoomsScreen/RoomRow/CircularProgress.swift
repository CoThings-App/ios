//
//  CircularPercentage.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/04.
//  Copyright © 2020 CoThings. All rights reserved.
//

import SwiftUI

struct CircularProgress: View {
    let percentage: Float

    @Environment(\.colorScheme) var colorScheme

    fileprivate static let colors: [(Float, ProgressColor)] = [
        (0.6, ProgressColor(.hex("C8FF3F"), .hex("B4E33E"))),
        (0.8, ProgressColor(.hex("FFC000"), .hex("EBA90E"))),
        (Float.infinity, ProgressColor(.hex("E64200"), .hex("B92D1A")))
    ]

    var body: some View {
        var donutColor = CircularProgress.colors.last!.1
        for (limit, nextDonutColor) in CircularProgress.colors {
            if percentage < limit {
                donutColor = nextDonutColor
                break
            }
        }

        return ZStack {
            Segment(percentage: 1)
                .fill(Color(UIColor.secondarySystemFill))

            if percentage > 0 {
                Segment(percentage: CGFloat(percentage))
                    .fill(donutColor.fill)

                Segment(percentage: CGFloat(percentage))
                    .stroke(donutColor.stroke)
            }
        }
        .padding(6)
        .frame(width: 65, height: 65)
    }
}

fileprivate struct ProgressColor {
    let fill: Color
    let stroke: Color

    init(_ fill: Color, _ stroke: Color) {
        self.fill = fill
        self.stroke = stroke
    }
}

fileprivate struct Segment: Shape {
    let percentage: CGFloat

    func path(in rect: CGRect) -> Path {
        let gapAngle: Double = 90
        let angle = CGFloat((Angle.degrees(360) - Angle.degrees(gapAngle)).degrees)
        return Circle()
            .trim(from: 0.0, to: angle * min(percentage, 1) / 360.0)
            .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
            .rotation(.degrees(90 + gapAngle / 2.0))
            .path(in: rect)

    }
}

struct CircularProgress_Previews: PreviewProvider {
    static var previews: some View {


        let segments =
        VStack(spacing: 20) {
            CircularProgress(percentage: 0.2)
            CircularProgress(percentage: 0.5)
            CircularProgress(percentage: 1.0)
            CircularProgress(percentage: 2.0)
            CircularProgress(percentage: 0.0)
        }
        .padding()

        return Group {
            segments
                .previewLayout(.sizeThatFits)

            segments
                .background(Color(UIColor.systemBackground))
                .colorScheme(.dark)
                .previewLayout(.sizeThatFits)
        }
    }
}
