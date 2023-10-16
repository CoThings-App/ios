//
//  AppRootView.swift
//  CoThings
//
//  Created by Neso on 2020/05/13.
//  Copyright © 2020 CoThings. All rights reserved.
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
            return AnyView(NavigationView {ServerSettingsView(stateController: stateController) })
        case let .ready(session: session):
            return AnyView(readyView(session))
        }
    }

    func readyView(_ session: PlaceSession) -> some View {
        let roomsController = RoomsController(session: session)

        return TabView {
            RoomsScreen(roomsController: roomsController)
                .tabItem {
                    Image(systemName: "house")
                    Text("Spaces")
                }

            SettingsScreen(stateController: self.stateController, session: session)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }

    var body: some View {
        screen
    }
}

struct RootView_Previews: PreviewProvider {
    static let readyStateController =
    StateController(state: .ready(session: previewSession), 
                    beaconDetector: previewBeaconDetector)

    static var previews: some View {
        Group {
            RootView(stateController: 
                        StateController(state: .configurationNeeded, beaconDetector: previewBeaconDetector)
            )

            RootView(stateController: Self.readyStateController)
        }
    }
}
