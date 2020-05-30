//
//  NotificationService.swift
//  CoThings
//
//  Created by Neso on 2020/05/30.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import Foundation
import Combine
import UserNotifications

class NotificationService: ObservableObject {

	@Published var showingAlert: Bool = false

	@Published var notifyOnEnter: Bool = UserDefaults.standard.bool(forKey: NotifyOnEnterKey) {
		didSet {
			UserDefaults.standard.set(self.notifyOnEnter, forKey: NotifyOnEnterKey)
			if self.notifyOnEnter {
				self.requestNotificationPermission()
			}
		}
	}

	@Published var notifyOnExit: Bool = UserDefaults.standard.bool(forKey: NotifyOnExitKey) {
		didSet {
			UserDefaults.standard.set(self.notifyOnExit, forKey: NotifyOnExitKey)
			if self.notifyOnExit {
				self.requestNotificationPermission()
			}
		}
	}

	@Published var notifyWithSound: Bool = UserDefaults.standard.bool(forKey: NotifyWithSoundKey) {
		didSet {
			UserDefaults.standard.set(self.notifyWithSound, forKey: NotifyWithSoundKey)
			if self.notifyWithSound {
				self.requestNotificationPermission()
			}
		}
	}

	@Published var notifyWithOneLineMessage: Bool = UserDefaults.standard.bool(forKey: NotifyWithOneLineMessageKey) {
		didSet {
			UserDefaults.standard.set(self.notifyWithOneLineMessage, forKey: NotifyWithOneLineMessageKey)
		}
	}

	func requestNotificationPermission() {
		let notificationCenter = UNUserNotificationCenter.current()
		let options: UNAuthorizationOptions = [.alert, .sound]
		notificationCenter.requestAuthorization(options: options) {
			(didAllow, _) in
			if !didAllow {
				 DispatchQueue.main.async {
					self.showingAlert = self.shouldShowAlert()
				}
			}
		}
		notificationCenter.getNotificationSettings { (settings) in
			if settings.authorizationStatus != .authorized {
				 DispatchQueue.main.async {
					self.showingAlert = self.shouldShowAlert()
				}
			}
		}
	}

	private func shouldShowAlert() -> Bool {
		return notifyOnEnter || notifyOnExit || notifyWithSound
	}

	func showPushNotificationIfEnabled(for actionEntered: Bool, title: String, message: String) {

		if (actionEntered && !notifyOnEnter) {
			return
		}

		if (!actionEntered && !notifyOnExit) {
			return
		}

		let content = UNMutableNotificationContent()

		content.title = !notifyWithOneLineMessage ? title : title + " " + message

		if !notifyWithOneLineMessage {
			content.body = message
		}

		if notifyWithSound {
			content.sound = .default
		}

		let request = UNNotificationRequest(identifier: "CoThingsNotificationId_" + String(Int.random(in: 200...300)),
											content: content,
											trigger: nil)

		let userNotificationCenter = UNUserNotificationCenter.current()
		userNotificationCenter.add(request)
	}


}
