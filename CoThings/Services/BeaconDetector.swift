//
//  BeaconDetector.swift
//  CoThings
//
//  Created by Neso on 2020/05/13.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import Foundation
import CoreLocation
import Combine
#if DEBUG
import UserNotifications
#endif

struct BeaconIdentity: Hashable {
    let uuid: UUID
    let major: CLBeaconMajorValue
    let minor: CLBeaconMinorValue
}

extension Room {
    var beaconIdentity: BeaconIdentity? {
        guard let uuid = self.iBeaconUUID, let minor = self.minor, let major = self.major else { return nil }
        return BeaconIdentity(uuid: uuid,
                              major: CLBeaconMajorValue(major),
                              minor: CLBeaconMinorValue(minor))
    }
}

extension CLBeacon {
    var beaconIdentity: BeaconIdentity {
        return BeaconIdentity(uuid: self.uuid,
                              major: CLBeaconMajorValue(truncating: self.major),
                              minor: CLBeaconMinorValue(truncating: self.minor))
    }
}

struct Beacon {
    var proximity: CLProximity
    var strength: Int
    var accuracy: Double
    var constraint: CLBeaconIdentityConstraint
    var region: CLBeaconRegion
    var roomID: Room.ID
}

class BeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var beacons: [BeaconIdentity: Beacon] = [:]
    @Published private(set) var permissionGranted: Bool? = nil
    
    private(set) var enters = PassthroughSubject<Room.ID, Never>()
    private(set) var exits = PassthroughSubject<Room.ID, Never>()

	private var locationManager = CLLocationManager()

    override init() {
        super.init()

		locationManager.delegate = self
		locationManager.requestAlwaysAuthorization()
	}
    
    func startScanning(room: Room) {
        guard let beaconID = room.beaconIdentity,
            beacons[beaconID] == nil else { return }
        
        let constraint = CLBeaconIdentityConstraint(uuid: beaconID.uuid,
                                                    major: beaconID.major,
                                                    minor: beaconID.minor)

		let beaconRegion = CLBeaconRegion(uuid: beaconID.uuid, identifier: String(room.id))
		locationManager.startMonitoring(for: beaconRegion) // need it for start background monitoring

		locationManager.startRangingBeacons(satisfying: constraint)
        beacons[beaconID] = Beacon(proximity: .unknown,
                                   strength: 0,
                                   accuracy: 0,
                                   constraint: constraint,
                                   region: beaconRegion,
                                   roomID: room.id)
    }
    
    func stopScanning(room: Room) {
        guard let beaconID = room.beaconIdentity,
            let beacon = beacons[beaconID] else { return }


		let beaconRegion = CLBeaconRegion(uuid: beaconID.uuid, identifier: String(room.id))
		locationManager.stopMonitoring(for: beaconRegion) // need it for stop background monitoring

        locationManager.stopRangingBeacons(satisfying: beacon.constraint)
        beacons.removeValue(forKey: beaconID)
    }
    
    func stopScanningAll() {
        for (_, beacon) in self.beacons {
            locationManager.stopRangingBeacons(satisfying: beacon.constraint)
            locationManager.stopMonitoring(for: beacon.region)
        }
        
        self.beacons = [:]
    }

    // MARK: - CLLocationManager delegate
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                permissionGranted = true
                return
            }
        }
        
        permissionGranted = false
    }

	internal func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		#if DEBUG
		print("monitored region count:\(locationManager.monitoredRegions.count)")
		print("beacon count= \(beacons.count)")

		for beacon in beacons {
			let beaconID = beacon.beaconIdentity
			guard var oldBeacon = self.beacons[beaconID] else { continue }

			oldBeacon.proximity = beacon.proximity
			oldBeacon.strength = beacon.rssi
			oldBeacon.accuracy = beacon.accuracy
			self.beacons[beaconID] = oldBeacon
		}

		#endif

	}

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		guard let beaconRegion = region as? CLBeaconRegion else { return }
		updateRoomStatus(for: beaconRegion, isEntered: true)
	}

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		guard let beaconRegion = region as? CLBeaconRegion else { return }
		updateRoomStatus(for: beaconRegion, isEntered: false)
	}

	func updateRoomStatus(for beaconRegion: CLBeaconRegion, isEntered: Bool) {
		let beaconIdentifier = beaconRegion.identifier
		guard let roomId = Int(beaconIdentifier) else { return } // beaconIdentifer = room.ID



		// in our case one user (or device) can be only in one room at the same time,
		// so if the user (or the device) if in the room it should exit first,
		// in order to enter the room

		let lastEnteredRoomId = UserDefaults.standard.integer(forKey: LastEnteredRoomIdKey)

		#if DEBUG
		print("roomId: \(roomId) lastEnteredRoomId: \(lastEnteredRoomId) isEntered: \(isEntered)")
		#endif
		if lastEnteredRoomId == 0 {
			// probably first time
			isEntered ? enterTo(room: roomId) : removeFrom(room: roomId)
		} else {
			if lastEnteredRoomId != roomId {
				removeFrom(room: lastEnteredRoomId)
			}
			isEntered ? enterTo(room: roomId) : removeFrom(room: roomId)
		}

		#if DEBUG
		print("monitored region count:\(locationManager.monitoredRegions.count)")
		push(roomId: roomId, isEntered: isEntered)
		#endif
	}

	internal func enterTo(room roomId: Int) {
		enters.send(roomId)
		UserDefaults.standard.set(roomId, forKey: LastEnteredRoomIdKey)
	}

	internal func removeFrom(room roomId: Int) {
		exits.send(roomId)
		UserDefaults.standard.removeObject(forKey: LastEnteredRoomIdKey)
	}

	internal func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		print("Failed monitoring region: \(error.localizedDescription)")
	}

	internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Location manager failed: \(error.localizedDescription)")
	}

	#if DEBUG
	func push(roomId: Int, isEntered: Bool) {
		let content = UNMutableNotificationContent()

		let action = isEntered ? "Enter" : "Exit"

		content.title = "CoThings Room: \(roomId)"
		content.body = "Action:\(action) beacon count:\(self.beacons.count)"
		content.sound = .default

		let request = UNNotificationRequest(identifier: "testNotification" + String(Int.random(in: 200...300)),
											content: content,
											trigger: nil)

		let userNotificationCenter = UNUserNotificationCenter.current()
		userNotificationCenter.add(request)

	}
	#endif
}
