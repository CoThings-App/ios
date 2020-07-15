//
//  PlaceHeaderView.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/04.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct PlaceHeaderView: View {
    @Environment(\.statusBarHeight) var statusBarHeight: CGFloat
    static let titleFont = Font.custom("Avenir", size: 24).weight(.black)
    
    let title: String
	let imageUrl: String
    
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
                Spacer()
            }
            .padding(.top, statusBarHeight)
            .frame(maxWidth: .infinity)
        }
        .background(
			WebImage(url: URL(string: imageUrl))
				.resizable()
				.placeholder(Image("place-photo"))
				.indicator(.activity)
				.transition(.fade(duration: 0.5))
				.aspectRatio(contentMode: .fill)
        )
        .clipped()
    }
}

struct PlaceHeaderView_Previews: PreviewProvider {
    static var previews: some View {
		let headerView = PlaceHeaderView(title: "CoThings", imageUrl: "https://demo.cothings.app/images/app_image.jpg")
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
