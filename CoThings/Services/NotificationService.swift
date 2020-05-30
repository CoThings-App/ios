//
//  NotificationService.swift
//  CoThings
//
//  Created by Neso on 2020/05/30.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import Foundation
import Combine

class NotificationService: ObservableObject {

	@Published var notifyOnEnter: Bool = UserDefaults.standard.bool(forKey: NotifyOnEnterKey) {
		didSet {
			UserDefaults.standard.set(self.notifyOnEnter, forKey: NotifyOnEnterKey)
		}
	}

	@Published var notifyOnExit: Bool = UserDefaults.standard.bool(forKey: NotifyOnExitKey) {
		didSet {
			UserDefaults.standard.set(self.notifyOnExit, forKey: NotifyOnExitKey)
		}
	}

	@Published var notifyWithSound: Bool = UserDefaults.standard.bool(forKey: NotifyWithSoundKey) {
		didSet {
			UserDefaults.standard.set(self.notifyWithSound, forKey: NotifyWithSoundKey)
		}
	}
}
