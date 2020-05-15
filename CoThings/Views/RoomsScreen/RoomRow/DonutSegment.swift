//
//  CircularPercentage.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/04.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import SwiftUI

struct DonutColor {
    let fill: Color
    let stroke: Color
    
    init(_ fill: Color, _ stroke: Color) {
        self.fill = fill
        self.stroke = stroke
    }
}

struct DonutSegment: View {
    @Environment(\.colorScheme) var colorScheme
    
    let percentage: Float
    static let colors: [(Float, DonutColor)] = [
        (0.5, DonutColor(.hex("C8FF3F"), .hex("B4E33E"))),
        (1.0, DonutColor(.hex("FFC000"), .hex("EBA90E"))),
        (Float.infinity, DonutColor(.hex("E64200"), .hex("B92D1A")))
    ]

    var body: some View {
        var donutColor = DonutSegment.colors.last!.1
        for (limit, nextDonutColor) in DonutSegment.colors {
            if percentage < limit {
                donutColor = nextDonutColor
                break
            }
        }
        
        return ZStack {
            Donut(thickness: 12)
                .fill(Color(UIColor.secondarySystemFill))
            
            if percentage > 0 {
                Donut(thickness: 12, percentage: percentage)
                    .fill(donutColor.fill)
                    .opacity(colorScheme == .light ? 1.0 : 0.8)
                    
                Donut(thickness: 12, percentage: percentage)
                    .stroke(donutColor.stroke,
                            style: StrokeStyle(lineWidth: 1.2,
                                               lineCap: .round,
                                               lineJoin: .round,
                                               miterLimit: 1,
                                               dash: [],
                                               dashPhase: 0))
            }
            
        }.frame(width: 65, height: 65)
    }
}

struct Donut: Shape {
    let thickness: Float
    let percentage: Float
    
    init (thickness: Float, percentage: Float = 1.0) {
        self.thickness = thickness
        self.percentage = percentage
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint.init(x: rect.midX, y: rect.midY)
        let radius = rect.width - rect.midX
        var path = Path()
        
        let startAngle: Angle = .radians(Double.pi) - .degrees(50)
        let fullAngle: Angle = .radians(Double.pi * 2) + .degrees(50)
        
        let endAngle: Angle = min(startAngle + (fullAngle - startAngle) * Double(percentage), fullAngle)
        
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        
        path.addArc(center: center,
                    radius: radius-CGFloat(thickness),
                    startAngle: endAngle,
                    endAngle: startAngle,
                    clockwise: true)
        
        path.closeSubpath()
        
        return path
    }
}

struct DonutSegment_Previews: PreviewProvider {
    static var previews: some View {
        let segments =
            VStack(spacing: 20) {
                DonutSegment(percentage: 0.2)
                DonutSegment(percentage: 0.5)
                DonutSegment(percentage: 1.0)
                DonutSegment(percentage: 2.0)
                DonutSegment(percentage: 0.0)
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
