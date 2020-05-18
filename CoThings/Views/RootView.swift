//
//  AppRootView.swift
//  CoThings
//
//  Created by Neso on 2020/05/13.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI
import Combine

struct RootView: View {
	@ObservedObject var stateController: StateController
    
    private var screen: AnyView {
        switch stateController.appState {
        case .initialRun:
            return AnyView(OnBoardingScreen(stateController: stateController))
        case .configurationNeeded:
            return AnyView(ServerSettingsView(stateController: stateController))
        case let .ready(session: session):
            return AnyView(RoomsScreen(roomsController: RoomsController(session: session)))
        }
    }
    
	var body: some View {
        screen
	}
}

struct RootView_Previews: PreviewProvider {
    static let readyStateController =
        StateController(state: .ready(session: PlaceSession(service: InMemoryBackend())))
    
    static var previews: some View {
        Group {
            RootView(stateController: StateController(state: .configurationNeeded))
            
            RootView(stateController: Self.readyStateController)
        }
    }
}
