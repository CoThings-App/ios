//
//  DonutPercentageView.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/04.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import SwiftUI

struct DonutPercentageView: View {
    let percentage: Float
    
    static let percentageFont = Font.custom("DIN Condensed", size: 20).bold()
    
    var percentageText: String {
        percentage == 0 ? "―" : String(format: "%.0f%%", percentage * 100.0)
    }
    
    var textColor: Color {
        percentage == 0 ? Color(UIColor.tertiaryLabel) : .primary
    }
    
    var body: some View {
        ZStack {
            DonutSegment(percentage: percentage)
            
            Text(percentageText)
                .foregroundColor(textColor)
                .font(DonutPercentageView.percentageFont)
                .padding(.top, 5)
        }
    }
}

struct DonutPercentageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            DonutPercentageView(percentage: 0.25)
            DonutPercentageView(percentage: 0.583)
            DonutPercentageView(percentage: 0.91234)
            DonutPercentageView(percentage: 1.0)
            DonutPercentageView(percentage: 2.0)
            DonutPercentageView(percentage: 0)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
