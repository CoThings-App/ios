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

class BeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {

	var didChange = PassthroughSubject<CLProximity, Never>()
	var localitionManager: CLLocationManager?
	@Published var lastDistance = CLProximity.unknown

	override init() {
		super.init()

		localitionManager = CLLocationManager()
		localitionManager?.delegate = self
		localitionManager?.requestAlwaysAuthorization()
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

		localitionManager?.startMonitoring(for: beaconRegion)
		localitionManager?.startRangingBeacons(satisfying: constraint)

//		print("looking for beacons")
	}

	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		if let beacon = beacons.first {
//			print("beacon found.");
			update(distance: beacon.proximity)
		} else {
//			print("NO beacon found!")
			update(distance: .unknown)
		}
	}

	func update(distance: CLProximity) {
		lastDistance = distance
		didChange.send(lastDistance)
	}
}
