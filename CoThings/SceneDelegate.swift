//
//  SceneDelegate.swift
//  CoThings
//
//  Created by Neso on 2020/05/01.
//  Copyright © 2020 CoThings. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        let beaconDetector = BeaconDetector()
        let session = UserDefaults.standard.string(forKey: ServerHostNameKey)
            .map { hn in ServerBackend(hostname: hn) }
            .map { server in PlaceSession(service: server, beaconDetector: beaconDetector) }
            .map { session in AppState.ready(session: session) }

        let initialRun = UserDefaults.standard.bool(forKey: PassOnboardingKey)
        ? AppState.configurationNeeded
        : AppState.initialRun

        let appState = session ?? initialRun
        let stateController = StateController(state: appState, beaconDetector: beaconDetector)

        if let windowScene =  scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)

            let rootView = RootView(stateController: stateController)
                .environment(\.hostingWindow, { self.window })

            self.window?.rootViewController = CoHostingController(rootView: rootView)
            self.window?.makeKeyAndVisible()
        }
    }
}
