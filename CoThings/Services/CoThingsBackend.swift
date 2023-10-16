//
//  CoThingsService.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/16.
//  Copyright © 2020 CoThings. All rights reserved.
//

import Combine

enum ConnectionStatus: String {
    case connecting
    case ready
    case failed
    case disconnected
}

struct UpdateError: Error {
    var localizedDescription: String {
        "failed to update room"
    }
}

protocol CoThingsBackend {

    typealias CompletionHandler = (Result<Void, UpdateError>) -> Void

    var status: ConnectionStatus { get }
    var statusPublisher: AnyPublisher<ConnectionStatus, Never> { get }

    var rooms: [Room] { get }
    var roomsPublisher: AnyPublisher<[Room], Never> { get }

    func connectInBackground()

    func disconnectInBackground()

    func increasePopulation(roomID: Room.ID,
                            completionHandler: @escaping CompletionHandler)

    func decreasePopulation(roomID: Room.ID,
                            completionHandler: @escaping CompletionHandler)
}
