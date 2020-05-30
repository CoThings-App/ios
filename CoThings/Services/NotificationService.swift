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
				self.notificationRequest()
			}
		}
	}

	@Published var notifyOnExit: Bool = UserDefaults.standard.bool(forKey: NotifyOnExitKey) {
		didSet {
			UserDefaults.standard.set(self.notifyOnExit, forKey: NotifyOnExitKey)
			if self.notifyOnExit {
				self.notificationRequest()
			}
		}
	}

	@Published var notifyWithSound: Bool = UserDefaults.standard.bool(forKey: NotifyWithSoundKey) {
		didSet {
			UserDefaults.standard.set(self.notifyWithSound, forKey: NotifyWithSoundKey)
			if self.notifyWithSound {
				self.notificationRequest()
			}
		}
	}

	func notificationRequest() {
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

	func shouldShowAlert() -> Bool {
		return notifyOnEnter || notifyOnExit || notifyWithSound
	}


}
