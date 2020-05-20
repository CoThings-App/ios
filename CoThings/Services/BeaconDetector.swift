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
		let uuid = UUID(uuidString: "")!
		let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: 1, minor: 10)
		let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "")

		localitionManager.startMonitoring(for: beaconRegion)
		localitionManager.startRangingBeacons(satisfying: constraint)
	}

	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		if let beacon = beacons.first {
			update(distance: beacon.proximity)
		} else {
			update(distance: .unknown)
		}
	}

	func update(distance: CLProximity) {
		lastDistance = distance
		didChange.send(lastDistance)
	}
}
