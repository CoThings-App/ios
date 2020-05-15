//
//  AppRootView.swift
//  CoThings
//
//  Created by Neso on 2020/05/13.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI
import Combine

struct AppRootView: View {
	@ObservedObject var appState: AppState
    let roomColl = RoomCollection(from: rooms)
	var body: some View {
		Group {
			if appState.serverHostnameIsSet {
//				HomeView()
//				BeaconView()
                RoomsScreen(rooms: roomColl)
			} else {
				ServerSettingsView(appState: self.appState)
			}
		}
	}
}

struct AppRootView_Previews: PreviewProvider {
    static let state: AppState = {
        let s = AppState()
        s.serverHostnameIsSet = true
        return s
    }()
    
    static var previews: some View {
        AppRootView(appState: state)
    }
}
