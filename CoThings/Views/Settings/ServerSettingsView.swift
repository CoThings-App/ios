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

struct ServerSettingsView: View {
	@ObservedObject var stateController: StateController
    @State var serverHostname: String = ""
    
    var isHostnameValid: Bool {
        if serverHostname.starts(with: "https://") {
            return URL(string: serverHostname) != nil
        } else {
            return URL(string: "https://" + serverHostname) != nil
        }
    }
    
	var body: some View {
		NavigationView {
            Form {
                Section(header: Text("Server URL")) {
                    HStack(alignment: .firstTextBaseline, spacing: 1) {
                        Text("https://")
                        TextField("demo.cothings.app", text: $serverHostname)
                            .keyboardType(.URL)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationBarTitle("Server Settings", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done", action: self.save).disabled(!isHostnameValid)
            )
        }
	}
    
    func save() {
        var cleanHostname = serverHostname
        if serverHostname.hasPrefix("https://") {
            cleanHostname = String(serverHostname.dropFirst("https://".count))
        }

        stateController.saveConfiguration(hostname: cleanHostname)
    }
}

struct OnBoardView_Previews: PreviewProvider {
	static var previews: some View {
        ServerSettingsView(stateController: StateController(state: .configurationNeeded))
	}
}
