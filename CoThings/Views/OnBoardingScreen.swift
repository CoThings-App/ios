//
//  OnBoardingScreen.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/15.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI

struct OnBoardingScreen: View {
    @ObservedObject var stateController: StateController
    
    var body: some View {
        Text("Onboarding")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(Button("Skip", action: stateController.completeOnBoarding).padding(), alignment: .topTrailing)
    }
}

struct OnBoardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingScreen(stateController: StateController(state: .initialRun))
    }
}
