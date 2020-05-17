//
//  Session.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/05.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import SwiftUI
import Combine

class PlaceSession: ObservableObject {
    @Published var connectionStatus: ConnectionStatus
    @Published var rooms: [Room]
    
    private let service: CoThingsBackend
    private var roomsCancellable: AnyCancellable?
    private var connectionStatusCancellable: AnyCancellable?
    
    init(service: CoThingsBackend) {
        self.service = service
        self.rooms = []
        self.connectionStatus = service.status
        
        self.roomsCancellable = self.service.roomsPublisher
            .assign(to: \.rooms, on: self)
        
        self.connectionStatusCancellable = self.service.statusPublisher
            .assign(to: \.connectionStatus, on: self)
    }
    
    func increasePopulation(room: Room) {
        guard
            connectionStatus == .ready,
            let roomIndex = rooms.firstIndex(of: room) else {
            return
        }
        
        var newRoom = rooms[roomIndex]
        newRoom.population += 1
        rooms[roomIndex] = newRoom
        
        service.increasePopulation(room: room) { res in
            if case .failure = res {
                self.rooms = self.service.rooms
            }
        }
    }
    
    func decreasePopulation(room: Room) {
        guard
            connectionStatus == .ready,
            let roomIndex = rooms.firstIndex(of: room) else {
            return
        }
        
        var newRoom = rooms[roomIndex]
        newRoom.population -= 1
        rooms[roomIndex] = newRoom
        
        service.decreasePopulation(room: room) { res in
            if case .failure = res {
                self.rooms = self.service.rooms
            }
        }
    }
}
