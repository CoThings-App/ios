//
//  OnBoardingScreen.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/15.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI

struct BigText: ViewModifier {

	func body(content: Content) -> some View {
		content
			.font(Font.system(size: 50, design: .rounded))
			.frame(minWidth: 0, maxWidth: .infinity, minHeight:100, maxHeight: 100)
			.layoutPriority(1)
	}
}

struct OnBoardingScreen: View {
    @ObservedObject var stateController: StateController
    
    var body: some View {

		VStack {
			Image("launcher")
				.resizable()
				.frame(width: 96.0, height: 96.0)

			Text("CoThings").modifier(BigText())
			.padding(.all, -10.0)
			Text("is a realtime counter for shared things.")
				.italic()
				.foregroundColor(Color.gray)
				.multilineTextAlignment(.center)

			Text("It accounts for the current number of people using shared areas like the kitchen or utilities like washing machines, dryers in realtime, using iBeacons as optional.\n\nTo run this application you need a server. If you don't have a server you can contact us to have one. If you already have one please set the URL in the next screen.\n\nIf you want to test the app you can use our demo server on the next screen.")
				.fontWeight(.medium)
				.multilineTextAlignment(.leading)
				.padding(.top, 10.0)
				.padding(.horizontal, 20.0)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.overlay(Button("Next", action: stateController.completeOnBoarding).padding(), alignment: .topTrailing)
    }
}

struct OnBoardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingScreen(stateController: StateController(state: .initialRun, beaconDetector: previewBeaconDetector))
    }
}
