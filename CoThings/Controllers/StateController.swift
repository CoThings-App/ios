//
//  AppRootController.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/15.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import Foundation

class StateController: ObservableObject {
    @Published var appState: AppState
    
    init(state: AppState) {
        appState = state
    }
    
    func completeOnBoarding() {
        UserDefaults.standard.set(true, forKey: PassOnboardingKey)
        appState = .configurationNeeded
    }
    
    func saveConfiguration(hostname: String) {
        UserDefaults.standard.set(hostname, forKey: ServerHostNameKey)
        appState = .ready(session: Self.sessionFrom(hostname: hostname))
    }
    
    private static func sessionFrom(hostname: String) -> PlaceSession {
        return PlaceSession(service: ServerBackend(hostname: hostname))
    }
}
