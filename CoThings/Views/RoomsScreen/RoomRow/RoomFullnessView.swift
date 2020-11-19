//
//  DonutPercentageView.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/04.
//  Copyright © 2020 CoThings. All rights reserved.
//

import SwiftUI

struct RoomFullnessView: View {
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
            CircularProgress(percentage: percentage)
            
            Text(percentageText)
                .foregroundColor(textColor)
                .font(RoomFullnessView.percentageFont)
                .padding(.top, 5)
        }
    }
}

struct RoomFullnessView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            RoomFullnessView(percentage: 0.25)
            RoomFullnessView(percentage: 0.583)
            RoomFullnessView(percentage: 0.91234)
            RoomFullnessView(percentage: 1.0)
            RoomFullnessView(percentage: 2.0)
            RoomFullnessView(percentage: 0)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
