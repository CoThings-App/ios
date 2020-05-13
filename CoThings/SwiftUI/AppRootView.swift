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
	var body: some View {
		Group {
			if appState.serverHostnameIsSet {
				HomeView()
			} else {
				ServerSettingsView(appState: self.appState)
			}
		}
	}
}
