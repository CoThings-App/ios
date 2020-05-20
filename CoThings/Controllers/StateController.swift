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
    let beaconDetector: BeaconDetector
    
    init(state: AppState, beaconDetector: BeaconDetector) {
        appState = state
        self.beaconDetector = beaconDetector
    }
    
    func completeOnBoarding() {
        UserDefaults.standard.set(true, forKey: PassOnboardingKey)
        appState = .configurationNeeded
    }
    
    func saveConfiguration(hostname: String) {
        UserDefaults.standard.set(hostname, forKey: ServerHostNameKey)
        appState = .ready(session: Self.sessionFrom(hostname: hostname, beaconDetector: beaconDetector))
    }
    
    private static func sessionFrom(hostname: String, beaconDetector: BeaconDetector) -> PlaceSession {
        return PlaceSession(service: ServerBackend(hostname: hostname), beaconDetector: beaconDetector)
    }
}
