//
//  NotificationSettings.swift
//  CoThings
//
//  Created by Neso on 2020/05/30.
//  Copyright © 2020 CoThings. All rights reserved.
//

import SwiftUI

struct NotificationSettings: View {

	@ObservedObject var userPreferences: UserPreferences
	@ObservedObject var notificationService: NotificationService

	var body: some View {
		Form {
			Section {
				Toggle(isOn: $userPreferences.notifyOnEnter) {
					Text("Notify on enter")
				}
				Toggle(isOn: $userPreferences.notifyOnExit) {
					Text("Notify on exit")
				}
				Toggle(isOn: $userPreferences.notifyWithSound) {
					Text("Notify with sound")
				}
				Toggle(isOn: $userPreferences.optimizeNotificationsForSmartWatches) {
					VStack(alignment: .leading, spacing: 0, content: {
						Text("Optimize for smart watches")
						Text("For small smart watch screens")
							.font(.footnote)
							.foregroundColor(.gray)
					})
				}
			}
			if !notificationService.permissionGranted && (userPreferences.notifyOnEnter || userPreferences.notifyOnExit) {
				Button("Allow Notifications") {
					UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
				}
			}
		}.navigationBarTitle("Notifications")
			.onAppear() {
				self.notificationService.requestNotificationPermission()
		}
	}
}

struct NotificationSettings_Previews: PreviewProvider {
	static let userPreferences = UserPreferences()
	static var previews: some View {
		NavigationView {
			NotificationSettings(userPreferences: userPreferences, notificationService: NotificationService(userPreferences: userPreferences))
		}
	}
}


