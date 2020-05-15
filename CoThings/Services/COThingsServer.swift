//
//  CoThingsServer.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/05.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import Foundation
import Combine
import SwiftPhoenixClient

enum ConnectionStatus: String {
    case connecting
    case connected
    case disconnected
    case failed
}

struct UpdateError: Error {
    var localizedDescription: String {
        "failed to update room"
    }
}

class CoThingsServer: ObservableObject {
    let url: URL
    let socketURL: URL
    
    @Published private(set) var connectionStatus: ConnectionStatus
    @Published private(set) var rooms: [Room]
    
    private let socket: Socket
    private var lobbyChan: Channel?
    
    init(url: URL, socketURL: URL) {
        self.url = url
        self.socketURL = socketURL
        self.socket = Socket(socketURL.absoluteString)
        
        self.connectionStatus = .connecting
        self.rooms = []
        
        self.socket.delegateOnOpen(to: self) { s in s.didSocketConnected() }
        self.socket.delegateOnClose(to: self) { s in s.didSocketClosed() }
        self.socket.delegateOnError(to: self) { (s, err) in s.didSocketErrored(error: err) }
    }
    
    func increasePopulation(room: Room, completionHandler: @escaping (Result<Void, UpdateError>) -> Void) {
        guard let lobbyChan = lobbyChan else {
            print("failed to increase population for \(room.name), because there is no active channel")
            completionHandler(.failure(UpdateError()))
            return
        }
        
        lobbyChan.push("inc", payload: [String : Any]())
            .receive("ok", callback: { _ in completionHandler(.success(())) })
            .receive("error", callback: { _ in completionHandler(.failure(UpdateError())) })
    }
    
    func decreasePopulation(room: Room, completionHandler: @escaping (Result<Void, UpdateError>) -> Void) {
        guard let lobbyChan = lobbyChan else {
            print("failed to decrease population for \(room.name), because there is no active channel")
            completionHandler(.failure(UpdateError()))
            return
        }
        
        lobbyChan.push("dec", payload: [String: Any]())
            .receive("ok", callback: { _ in completionHandler(.success(()))})
            .receive("error", callback: { _ in completionHandler(.failure(UpdateError()))})
    }
    
    private func didSocketConnected() {        
        lobbyChan = socket.channel("lobby:*")
        lobbyChan?.join()
            .delegateReceive("ok", to: self, callback: { (s, m) in s.didJoinedLobby(msg: m) })
            .delegateReceive("error", to: self) { (s, m) in s.didFailJoinLobby(msg: m) }
    }
    
    private func didFailJoinLobby(msg: Message) {
        connectionStatus = .failed
        print("error: failed to join lobby")
    }
    
    private func didJoinedLobby(msg: Message) {
        connectionStatus = .connected
        
        print("joined to lobby")
        guard let roomsDict = msg.payload["rooms"] as? [[String:Any]] else {
            print("Got an unexpected payload from joining the lobby channel")
            return
        }
        
        lobbyChan?.delegateOn("update", to: self) { s, m in
            guard let rooms = m.payload["rooms"] as? [[String:Any]] else {
                print("Got an unexpected payload from lobby on update message, no rooms")
                return
            }
            
            s.updateRooms(from: rooms)
        }
        
        updateRooms(from: roomsDict)
    }
    
    private func updateRooms(from dicts: [[String:Any]]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dicts, options: .fragmentsAllowed)
            self.rooms = try JSONDecoder().decode([Room].self, from: jsonData)
        } catch {
            print("Got unexpeced payload for rooms data")
        }
    }
    
    private func didSocketClosed() {
        self.connectionStatus = .disconnected
    }
    
    private func didSocketErrored(error: Error) {
        
    }
}
