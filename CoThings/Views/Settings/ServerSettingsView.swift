//
//  OnBoardView.swift
//  CoThings
//
//  Created by Neso on 2020/05/10.
//  Copyright © 2020 CoThings. All rights reserved.
//

import SwiftUI
import Foundation
import Combine
import CoreLocation

struct ServerSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
	@ObservedObject var stateController: StateController
    @State var serverHostname: String = UserDefaults.standard.string(forKey: ServerHostNameKey) ?? ""
    
    @State var isScanningQRCode: Bool = false
    @State var showCameraErrorAlert: Bool = false
	@State var showingPrivacyPolicy: Bool = false
	@State var askedForReadingPrivacy = false
    
    var isHostnameValid: Bool {
        if serverHostname.starts(with: "https://") {
            return URL(string: serverHostname) != nil
        } else {
            return URL(string: "https://" + serverHostname) != nil
        }
    }
    
	var body: some View {
        ZStack{
            Form {
                Section(header: Text("Server URL")) {
                    HStack(spacing: 1) {
                        TextField("", text: .constant("https://"))
                            .disabled(true)
                            .fixedSize()
                        TextField("demo.cothings.app", text: self.$serverHostname)
                            .keyboardType(.URL)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .frame(maxWidth: .infinity)
                            .layoutPriority(1)
                        Button(action: {
                            self.isScanningQRCode = true
                        }) {
                            Image("qrIcon")
                                .resizable()
                                .frame(minWidth: 35)
                                .scaledToFit()
                        }
                        
                    }
                }
                Section {
					Button("Done", action: self.save)
						.disabled(!(self.serverHostname.count > 2 && self.serverHostname.contains(".")))
					Button("Use Demo Server to see how it's like", action:  {
						self.serverHostname = "demo.cothings.app"
					})
                }
            }
            .sheet(isPresented: $isScanningQRCode) {
                QRCodeView(
                    onFoundCode: { (code) in
                        self.isScanningQRCode = false
                        self.parseQRCode(code: code)
                    },
                    onCameraError: {
                        self.showCameraErrorAlert = true
                    }
                )
            }
			.alert(isPresented: $showingPrivacyPolicy) {
				Alert(title: Text("Privacy Policy"),
					  message: Text("Please take a few minutes to read the policy before using the application.\n\n This action will open the privacy policy in your browser for the server: \(self.serverHostname)"),
					  primaryButton: .default(Text("OK, Let me read it!"), action: {
						UIApplication.shared.open(URL(string:"https://" +  self.serverHostname + "/privacy")!)
					}),
					  secondaryButton: .default(Text("I agree"), action: {
						self.askedForReadingPrivacy = true
						self.save()
					}))
			}
        }
        .background(colorScheme == .dark ? Color.black : Color(hex: "F5F6F7"))
        .navigationBarTitle("Server Settings", displayMode: .inline)
	}
    
    private func parseQRCode(code: String) {
        if(code.hasPrefix("https://")) {
            serverHostname = String(code.dropFirst("https://".count))
        } else {
            serverHostname = code
        }
    }
    
    private func save() {
		if !isHostnameValid {
			return
		}

		if !askedForReadingPrivacy {
			showingPrivacyPolicy = true
			return
		}

        stateController.saveConfiguration(hostname: serverHostname)
        presentationMode.wrappedValue.dismiss()
    }
}

struct OnBoardView_Previews: PreviewProvider {
	static var previews: some View {
        ServerSettingsView(stateController: StateController(state: .configurationNeeded,
                                                            beaconDetector: previewBeaconDetector))
	}
}
