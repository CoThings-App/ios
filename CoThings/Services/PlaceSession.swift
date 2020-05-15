//
//  Session.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/05.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import Foundation
import Combine

class PlaceSession: ObservableObject {
    @Published var connectionStatus: ConnectionStatus
    @Published var rooms: [Room]
    
    private let server: CoThingsServer
    private var roomsCancellable: AnyCancellable!
    private var connectionStatusCancellable: AnyCancellable!
    
    init(server: CoThingsServer) {
        self.server = server
        self.rooms = []
        
        self.connectionStatus = server.connectionStatus
        self.roomsCancellable = self.server.$rooms.assign(to: \.rooms, on: self)
        self.connectionStatusCancellable = self.server.$connectionStatus.assign(to: \.connectionStatus, on: self)
    }
    
    func increasePopulation(room: Room) {
        guard
            connectionStatus == .connected,
            let spaceIndex = rooms.firstIndex(of: room) else {
            return
        }
        
        var newSpace = rooms[spaceIndex]
        newSpace.population += 1
        rooms[spaceIndex] = newSpace
        
        server.increasePopulation(room: room) { res in
            if case .failure = res {
                self.rooms = self.server.rooms
            }
        }
    }
    
    func decreasePopulation(room: Room) {
        guard
            connectionStatus == .connected,
            let spaceIndex = rooms.firstIndex(of: room) else {
            return
        }
        
        var newSpace = rooms[spaceIndex]
        newSpace.population -= 1
        rooms[spaceIndex] = newSpace
        
        server.decreasePopulation(room: room) { res in
            if case .failure = res {
                self.rooms = self.server.rooms
            }
        }
    }
}
