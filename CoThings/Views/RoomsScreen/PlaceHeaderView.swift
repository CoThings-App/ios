//
//  PlaceHeaderView.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/04.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import SwiftUI

struct PlaceHeaderView: View {
    @Environment(\.statusBarHeight) var statusBarHeight: CGFloat
    static let titleFont = Font.custom("Avenir", size: 24).weight(.black)
    static let occupantsFont = Font.custom("Avenir Next", size: 18).weight(.medium)
    
    let title: String
    let population: Int
    
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(gradient: Gradient(colors: [
                Color.black.opacity(0.35),
                Color.black.opacity(0.6)
            ]), startPoint: .top, endPoint: .bottom)
            
            VStack(spacing: -2) {
                Spacer()
                Text(title.uppercased())
                    .font(PlaceHeaderView.titleFont)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 2)
                Text("\(population) Occupants")
                    .font(PlaceHeaderView.occupantsFont)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.5), radius: 1, x: 0, y: 1)
                Spacer()
            }
            .padding(.top, statusBarHeight)
            .frame(maxWidth: .infinity)
        }
        .background(
            Image("place-photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
        )
        .clipped()
    }
}

struct PlaceHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let headerView = PlaceHeaderView(title: "CoThings", population: 14)
            .edgesIgnoringSafeArea(.all)
        
        return Group {
            VStack {
                headerView
                    .frame(height: 125)
                    .overlay(
                        Rectangle().fill(Color.red.opacity(0.3)).frame(height: 125),
                        alignment: .top)
                Spacer()
            }
            .previewDevice("iPhone 8")
            
            VStack {
                headerView
                    .frame(height: 125)
                    .overlay(
                        Rectangle().fill(Color.red.opacity(0.3)).frame(height: 125),
                        alignment: .top)
                Spacer()
            }
            .previewDevice("iPhone 11")
        }
    }
}
