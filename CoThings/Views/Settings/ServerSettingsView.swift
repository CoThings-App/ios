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
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
	@ObservedObject var stateController: StateController
    @State var serverHostname: String = UserDefaults.standard.string(forKey: ServerHostNameKey) ?? ""
    
    @State var isScanningQRCode: Bool = false
    @State var showCameraErrorAlert: Bool = false
    
    var isHostnameValid: Bool {
        if serverHostname.starts(with: "https://") {
            return URL(string: serverHostname) != nil
        } else {
            return URL(string: "https://" + serverHostname) != nil
        }
    }
    
	var body: some View {
        ZStack{
            NavigationLink("Scan QR Code", destination: QRCodeView(
            onFoundCode: { (code) in
                self.isScanningQRCode = false
                self.parseQRCode(code: code)
            },
            onCameraError: {
                self.showCameraErrorAlert = true
            }
            ), isActive: $isScanningQRCode)
                .hidden()
                .alert(isPresented: $showCameraErrorAlert) { () -> Alert in
                    Alert(title: Text("Error"), message: Text("Cannot open camera.\nMake sure to allow CoThings to access your camera."), dismissButton: .default(Text("Back"), action: {
                        self.isScanningQRCode = false
                    }))
            }
            Form {
                Section(header: Text("Server URL")) {
                    GeometryReader { metrics in
                        HStack(alignment: .center, spacing: 1) {
                            Text("https://")
                            TextField("demo-eu.cothings.app", text: self.$serverHostname)
                                .keyboardType(.URL)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .frame(maxWidth: .infinity)
                            Image(self.colorScheme == .dark ? "qrWhiteIcon": "qrBlackIcon")
                                .resizable()
                                .frame(width: metrics.size.height, height: metrics.size.height)
                                .onTapGesture {
                                    self.isScanningQRCode = true
                                }
                        }
                    }
                }
                
                Section {
                    Button("Done", action: self.save)
                }
            }
        }
        .background(colorScheme == .dark ? Color.black : Color(hex: "F5F6F7"))
        .navigationBarTitle("Server Settings", displayMode: .inline)
	}
    
    private func save() {
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
