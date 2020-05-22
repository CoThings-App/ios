//
//  OnBoardView.swift
//  CoThings
//
//  Created by Neso on 2020/05/10.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI
import Foundation
import Combine
import CoreLocation

struct ServerSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    
	@ObservedObject var stateController: StateController
    @State var serverHostname: String = UserDefaults.standard.string(forKey: ServerHostNameKey) ?? ""
    
    var isHostnameValid: Bool {
        if serverHostname.starts(with: "https://") {
            return URL(string: serverHostname) != nil
        } else {
            return URL(string: "https://" + serverHostname) != nil
        }
    }
    
	var body: some View {
        Form {
            Section(header: Text("Server URL")) {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("https://")
                    TextField("demo-eu.cothings.app", text: $serverHostname)
                        .keyboardType(.URL)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .frame(maxWidth: .infinity)
                }
            }
            
            Section {
				Button("Done", action: self.save)
            }
        }
        .background(colorScheme == .dark ? Color.black : Color(hex: "F5F6F7"))
        .navigationBarTitle("Server Settings", displayMode: .inline)
	}
    
    func save() {
        var cleanHostname = serverHostname
        if serverHostname.hasPrefix("https://") {
            cleanHostname = String(serverHostname.dropFirst("https://".count))
        }
		stopMonitoringExistingBeacons()
        stateController.saveConfiguration(hostname: cleanHostname)
    }

	func stopMonitoringExistingBeacons() {
		let locationManager = CLLocationManager()
		for region in locationManager.monitoredRegions {
			locationManager.stopMonitoring(for: region)
		}
	}
}

struct OnBoardView_Previews: PreviewProvider {
	static var previews: some View {
        ServerSettingsView(stateController: StateController(state: .configurationNeeded, beaconDetector: previewBeaconDetector))
	}
}
