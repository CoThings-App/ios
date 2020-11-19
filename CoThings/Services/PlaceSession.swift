//
//  Session.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/05.
//  Copyright © 2020 CoThings. All rights reserved.
//

import SwiftUI
import Combine

class PlaceSession: ObservableObject {
    @Published var connectionStatus: ConnectionStatus
    @Published var rooms: [Room]
    
    let beaconDetector: BeaconDetector
	let userPreferences: UserPreferences
	let notificationService: NotificationService

	private let service: CoThingsBackend

    private var roomsCancellable: AnyCancellable?
    private var connectionStatusCancellable: AnyCancellable?
    private var beaconEnterCanceller: AnyCancellable?
    private var beaconExitCanceller: AnyCancellable?
	private var userPreferenceCanceller: AnyCancellable?

    init(service: CoThingsBackend, beaconDetector: BeaconDetector) {
        self.service = service
        self.rooms = []
        self.connectionStatus = service.status
        self.beaconDetector = beaconDetector
		self.userPreferences = UserPreferences()
		self.notificationService = NotificationService(userPreferences: self.userPreferences)

		self.userPreferenceCanceller = self.userPreferences.$notifyOnEnter.combineLatest(self.userPreferences.$notifyOnExit).sink { _ in
			self.onNotificationPreferenceChanged()
		}

		self.onNotificationPreferenceChanged()

        self.beaconDetector.stopScanningAll()
        self.roomsCancellable = self.service.roomsPublisher
            .sink {newRooms in
                for oldRoom in Set(self.rooms).subtracting(newRooms) {
                    self.beaconDetector.stopScanning(room: oldRoom)
                }
                
                for newRoom in Set(newRooms).subtracting(self.rooms) {
                    self.beaconDetector.startScanning(room: newRoom)
                }
                
                self.rooms = newRooms
            }
        
        self.connectionStatusCancellable = self.service.statusPublisher
            .assign(to: \.connectionStatus, on: self)
        
        beaconEnterCanceller = self.beaconDetector.enters.sink { roomID in
            self.increasePopulationInBackground(roomID: roomID)
			let title = self.createTitleForPushNotification(roomID)
			self.notificationService.show(on: .enters, title: title, message: "Entered")
        }
        
        beaconExitCanceller = self.beaconDetector.exits.sink { roomID in
            self.decreasePopulationInBackground(roomID: roomID)
			let title = self.createTitleForPushNotification(roomID)
			self.notificationService.show(on: .exits, title: title, message: "Exited")
        }
    }

	private func createTitleForPushNotification(_ roomId: Int) -> String {
		guard let room = self.rooms.first(where: {$0.id == roomId}) else {
			return "Room: \(roomId)";
		}
		return room.name
	}

	private func onNotificationPreferenceChanged() {
		if self.userPreferences.notifyOnEnter {
			self.notificationService.enableChannel(.enters)
		}

		if self.userPreferences.notifyOnExit {
			self.notificationService.enableChannel(.exits)
		}
	}

	private func ensureSocketConnection() {
		service.connectInBackground()
	}

	private func ensureSocketDisconnected() {
		service.disconnectInBackground()
	}
    
    func increasePopulation(roomID: Room.ID) {
        guard
            connectionStatus == .ready,
            let roomIndex = rooms.firstIndex(where: {$0.id == roomID}) else {
            return
        }
        
        var newRoom = rooms[roomIndex]
        newRoom.population += 1
        rooms[roomIndex] = newRoom
        
        service.increasePopulation(roomID: roomID) { res in
            if case .failure = res {
                self.rooms = self.service.rooms
            }
        }
    }
    
    func decreasePopulation(roomID: Room.ID) {
        guard
            connectionStatus == .ready,
            let roomIndex = rooms.firstIndex(where: {$0.id == roomID}) else {
            return
        }
        
        var newRoom = rooms[roomIndex]
        newRoom.population -= 1
        rooms[roomIndex] = newRoom
        
        service.decreasePopulation(roomID: roomID) { res in
            if case .failure = res {
                self.rooms = self.service.rooms
            }
        }
    }

	func increasePopulationInBackground(roomID: Room.ID) {
		ensureSocketConnection()
		service.increasePopulation(roomID: roomID) { _ in
			self.ensureSocketDisconnected()
		}
	}

	func decreasePopulationInBackground(roomID: Room.ID) {
		ensureSocketConnection()
		service.decreasePopulation(roomID: roomID) { _ in
			self.ensureSocketDisconnected()
		}
	}
}
