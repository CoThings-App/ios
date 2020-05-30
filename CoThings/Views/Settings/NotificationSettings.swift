//
//  NotificationSettings.swift
//  CoThings
//
//  Created by Neso on 2020/05/30.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI

struct NotificationSettings: View {

	@ObservedObject var notificationService = NotificationService()

	var body: some View {
		VStack(alignment: .trailing, spacing: 16, content: {
			Toggle(isOn: $notificationService.notifyOnEnter) {
				Text("Notify on Enter")
			}
			Toggle(isOn: $notificationService.notifyOnExit) {
				Text("Notify on Exit")
			}
			Toggle(isOn: $notificationService.notifyWithSound) {
				Text("Notify with Sound")
			}
			Toggle(isOn: $notificationService.notifyWithOneLineMessage) {
				VStack(alignment: .leading, spacing: 0, content: {
					Text("Show one line message")
					Text("For small smart watch screens")
						.font(.footnote)
						.foregroundColor(.gray)
				})
			}
			Spacer()
		}).navigationBarTitle("Notification")
			.padding(.all, 16)
			.alert(isPresented: $notificationService.showingAlert) {
					Alert(title: Text("Push Notification is disabled"),
						  message: Text("Please allow it in Settings"),
						  primaryButton: .cancel(),
						  secondaryButton: .default(Text("Settings"), action: {
							UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
						}))
		}
	}
}

struct NotificationSettings_Previews: PreviewProvider {
	static var previews: some View {
		NotificationSettings()
	}
}
