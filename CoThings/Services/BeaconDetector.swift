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

enum BeaconStatus: String {
	case found
	case lost
}

class BeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {

	var beaconExitTimer: Timer? = nil
	var entered: Bool = false

	var localitionManager = CLLocationManager()
	@Published var rooms: [Room]

	override init() {
		self.rooms = [

			// Sample Data
			Room(id: 1, name: "Cooking", group: "Common", population: 5, capacity: 12, lastUpdated: Date(), altBeaconUUID: nil, iBeaconUUID: UUID(uuidString: "9419F9BF-AC27-4F5A-8531-125CA957B139"), major: 1, minor: 10, beaconFound: false),
			Room(id: 2, name: "My Room", group: "Common", population: 1, capacity: 12, lastUpdated: Date(), altBeaconUUID: nil, iBeaconUUID: UUID(uuidString: "0DC76D8D-4197-4F32-ADD1-379E109AFC12"), major: 2, minor: 20, beaconFound: false)

		]
        super.init()

		localitionManager.delegate = self
		localitionManager.requestAlwaysAuthorization()
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedAlways || status == .authorizedWhenInUse {
			if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
				startScanning()
			} else {
				// TODO: warn user
			}
		}
	}

	func startScanning() {
		for room in self.rooms {
			if room.iBeaconUUID != nil {
				// no need to extra monitoring, when starting in ranging it will monitoring it
//				let beaconRegion = CLBeaconRegion(uuid: room.iBeaconUUID!, identifier: String(room.id))
//				localitionManager.startMonitoring(for: beaconRegion)
				let constraint = createConstraintForTheRoom(room: room)
				localitionManager.startRangingBeacons(satisfying: constraint)
			}
		}
	}

	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		if (beacons.count == 0) {
			return
		}

		 #if DEBUG
			print("monitored region count:\(localitionManager.monitoredRegions.count)")
			print("beacon count= \(beacons.count)")
		#endif

		for beacon in beacons {
			if let room = self.rooms.first(where: { $0.iBeaconUUID == beacon.uuid }) {
				let beaconStatus = beacon.proximity != .unknown
				let roomIndex = findRoomIndexByRegion(room: room)
				if (room.beaconFound != beaconStatus) {
					self.rooms[roomIndex].beaconFound = beaconStatus
					self.rooms[roomIndex].lastUpdated = Date()
				}
				self.rooms[roomIndex].info = "rssi: \(beacon.rssi)"
			}
		}
	}

	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		print("Failed monitoring region: \(error.localizedDescription)")
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Location manager failed: \(error.localizedDescription)")
	}

	func findRoomByRegion(region: CLRegion) -> Room {
		return self.rooms.first(where: { String($0.id) == region.identifier })!
	}

	func findRoomIndexByRegion(room: Room) -> Int {
		return self.rooms.firstIndex(of: room)!
	}

	func createConstraintForTheRoom(room: Room) -> CLBeaconIdentityConstraint {
		return CLBeaconIdentityConstraint(uuid: room.iBeaconUUID!, major: CLBeaconMajorValue(room.major!), minor: CLBeaconMinorValue(room.minor!))
	}
}
