//
//  InMemoryBackend.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/16.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import Foundation

class InMemoryBackend: CoThingsBackend {
    @Published var status: ConnectionStatus = .ready
    lazy var statusPublisher = $status.eraseToAnyPublisher()
    
    @Published var rooms: [Room] = previewRooms
    lazy var roomsPublisher = $rooms.eraseToAnyPublisher()
    
    func increasePopulation(room: Room, completionHandler: @escaping (Result<Void, UpdateError>) -> Void) {
        completionHandler(.success(()))
    }
    
    func decreasePopulation(room: Room, completionHandler: @escaping (Result<Void, UpdateError>) -> Void) {
        completionHandler(.success(()))
    }
}
