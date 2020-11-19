//
//  NotificationService.swift
//  CoThings
//
//  Created by Neso on 2020/05/30.
//  Copyright © 2020 CoThings. All rights reserved.
//

import Foundation
import Combine
import UserNotifications

enum NotificationChannel {
	case enters
	case exits
}

class NotificationService: ObservableObject {

	@Published private(set) var permissionGranted: Bool = false

	private let userPreferences: UserPreferences
	private var activeChannels: Set<NotificationChannel>

	init(userPreferences: UserPreferences) {
		self.userPreferences = userPreferences
		self.activeChannels = Set<NotificationChannel>()
		checkNotificationAuthorization()
	}

	func requestNotificationPermission() {
		let notificationCenter = UNUserNotificationCenter.current()
		let options: UNAuthorizationOptions = [.alert, .sound]
		notificationCenter.requestAuthorization(options: options) { didAllow, _ in
			DispatchQueue.main.async {
				self.permissionGranted = didAllow
			}
		}
//		checkNotificationAuthorization()
	}

	func checkNotificationAuthorization() {
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			DispatchQueue.main.async {
				self.permissionGranted = settings.authorizationStatus == .authorized
			}
		}
	}

	func show(on channel: NotificationChannel, title: String, message: String) {
		guard activeChannels.contains(channel) else { return }
		let content = UNMutableNotificationContent()

		content.title = userPreferences.optimizeNotificationsForSmartWatches ? title + " " + message : title
		content.body = userPreferences.optimizeNotificationsForSmartWatches ? "" : message

		if userPreferences.notifyWithSound {
			content.sound = .default
		}

		let request = UNNotificationRequest(identifier: "CoThingsNotification",
											content: content,
											trigger: nil)

		let userNotificationCenter = UNUserNotificationCenter.current()
		userNotificationCenter.add(request)
	}

	func enableChannel(_ channel: NotificationChannel) {
		activeChannels.insert(channel)
	}

	func disableChannel(_ channel: NotificationChannel) {
		activeChannels.remove(channel)
	}

}
