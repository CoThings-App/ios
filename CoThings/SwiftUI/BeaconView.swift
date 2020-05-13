//
//  BeaconView.swift
//  CoThings
//
//  Created by Neso on 2020/05/13.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI

struct BigText: ViewModifier {

	func body(content: Content) -> some View {
		content
			.font(Font.system(size: 50, design: .rounded))
			.frame(minWidth: 0, maxWidth: .infinity, minHeight:0, maxHeight: .infinity)
			.layoutPriority(1)
	}
}

struct BeaconView: View {

	@ObservedObject var detector: BeaconDetector = BeaconDetector()

	var body: some View {

		var text = ""
		var color = Color.blue

		switch self.detector.lastDistance {
			case .far:
				text = "FAR"
				color = Color.orange
			case .near:
				text = "NEAR"
				color = Color.green
			case .immediate:
				text = "IMMEDIATE"
				color = Color.yellow
			default:
				text = "NO BEACON"
				color = Color.gray
		}

        return Text(text)
			.modifier(BigText())
			.animation(Animation.easeIn(duration: 0.8))
			.background(color)
			.edgesIgnoringSafeArea(.all)

    }
}

struct BeaconView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconView()
    }
}
