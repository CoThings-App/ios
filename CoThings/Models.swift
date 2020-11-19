//
//  Models.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/04.
//  Copyright © 2020 CoThings. All rights reserved.
//

import Foundation

//TODO: convert to Enum
let ServerHostNameKey = "serverHostname"
let PassOnboardingKey = "passOnboarding"
let LastEnteredRoomIdKey = "lastEnteredRoomId"

struct Room: Identifiable {
    let id: Int
    var name: String
    var group: String
    var population: Int
    var capacity: Int
    var lastUpdated: Date
    
    var altBeaconUUID: String?
    var iBeaconUUID: UUID?
    var major: Int?
    var minor: Int?
    
    var percentage: Int {
        Int(population / capacity * 100)
    }
}

extension Room: Hashable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(iBeaconUUID)
        hasher.combine(major)
        hasher.combine(minor)
    }
}

extension Room: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case population = "count"
        case capacity
        case group
        case altBeaconUUID = "altbeacon_uuid"
        case iBeaconUUID = "ibeacon_uuid"
        case major
        case minor
        case lastUpdated = "updated_at"
    }
}

struct AppConfig: Codable {
	var title: String
	var imageUrl: String

}

class UserPreferences: ObservableObject {

	private enum Keys: String {
		case notifyOnEnter
		case notifyOnExit
		case notifyWithSound
		case optimizeNotificationsForSmartWatches
	}

	@Published var notifyOnEnter: Bool = UserDefaults.standard.bool(forKey: Keys.notifyOnEnter.rawValue) {
		didSet {
			UserDefaults.standard.set(self.notifyOnEnter, forKey: Keys.notifyOnEnter.rawValue)
		}
	}

	@Published var notifyOnExit: Bool = UserDefaults.standard.bool(forKey: Keys.notifyOnExit.rawValue) {
		didSet {
			UserDefaults.standard.set(self.notifyOnExit, forKey: Keys.notifyOnExit.rawValue)
		}
	}

	@Published var notifyWithSound: Bool = UserDefaults.standard.bool(forKey: Keys.notifyWithSound.rawValue) {
		didSet {
			UserDefaults.standard.set(self.notifyWithSound, forKey: Keys.notifyWithSound.rawValue)
		}
	}

	@Published var optimizeNotificationsForSmartWatches: Bool = UserDefaults.standard.bool(forKey: Keys.optimizeNotificationsForSmartWatches.rawValue) {
		didSet {
			UserDefaults.standard.set(self.optimizeNotificationsForSmartWatches, forKey: Keys.optimizeNotificationsForSmartWatches.rawValue)
		}
	}

}
