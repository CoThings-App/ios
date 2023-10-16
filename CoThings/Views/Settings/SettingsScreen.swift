//
//  SettingsScreen.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/20.
//  Copyright © 2020 CoThings. All rights reserved.
//

import SwiftUI

struct SettingsScreen: View {
    @Environment(\.colorScheme) var colorScheme

    let stateController: StateController
    let session: PlaceSession

    var body: some View {
        NavigationView {
            List {
                NavigationLink("Server Settings", destination: ServerSettingsView(stateController: stateController))

                NavigationLink("Notification Settings", destination: NotificationSettings(userPreferences: session.userPreferences, notificationService: session.notificationService))

#if DEBUG
                NavigationLink("Debugger", destination: DebugList(session: session))
#endif

                NavigationLink("About", destination: AboutView())
            }
            .background(colorScheme == .dark ? Color.black : Color(hex: "F5F6F7"))
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen(
            stateController:
                StateController(state: .ready(session: previewSession),
                                beaconDetector: previewBeaconDetector),
            session: previewSession)
    }
}
