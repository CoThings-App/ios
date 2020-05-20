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

class ServerBackend: ObservableObject, CoThingsBackend {
    let url: URL
    let socketURL: URL
    
    @Published private(set) var status: ConnectionStatus
    lazy var statusPublisher = $status.eraseToAnyPublisher()
    
    @Published private(set) var rooms: [Room]
    lazy var roomsPublisher = $rooms.eraseToAnyPublisher()
        
    private let socket: Socket
    private var lobbyChan: Channel?
    
    init(url: URL, socketURL: URL) {
        self.url = url
        self.socketURL = socketURL
        self.socket = Socket(socketURL.absoluteString)
        self.socket.timeout = TimeInterval(60)
        self.socket.connect()
		#if DEBUG
			self.socket.logger = { msg in print("LOG:", msg) }
		#endif
        
        self.status = .connecting
        self.rooms = []
        
        self.socket.delegateOnOpen(to: self) { s in s.didSocketConnected() }
        self.socket.delegateOnClose(to: self) { s in s.didSocketClosed() }
        self.socket.delegateOnError(to: self) { (s, err) in s.didSocketErrored(error: err) }
    }
    
    convenience init(hostname: String) {
        let url = URL(string: "https://" + hostname)!
        let socketURL = URL(string: "wss://" + hostname + "/socket")!
        
        self.init(url: url, socketURL: socketURL)
    }
    
    func increasePopulation(roomID: Room.ID, completionHandler: @escaping (Result<Void, UpdateError>) -> Void) {
        guard let lobbyChan = lobbyChan else {
            print("failed to increase population for \(roomID), because there is no active channel")
            completionHandler(.failure(UpdateError()))
            return
        }
        
        lobbyChan.push("inc", payload: ["room_id" : roomID])
            .receive("ok", callback: { _ in completionHandler(.success(())) })
            .receive("error", callback: { _ in completionHandler(.failure(UpdateError())) })
    }
    
    func decreasePopulation(roomID: Room.ID, completionHandler: @escaping (Result<Void, UpdateError>) -> Void) {
        guard let lobbyChan = lobbyChan else {
            print("failed to decrease population for \(roomID), because there is no active channel")
            completionHandler(.failure(UpdateError()))
            return
        }
        
        lobbyChan.push("dec", payload: ["room_id": roomID])
            .receive("ok", callback: { _ in completionHandler(.success(()))})
            .receive("error", callback: { _ in completionHandler(.failure(UpdateError()))})
    }
    
    // MARK: - Handle Socket Events
    
    private func didSocketConnected() {
        lobbyChan = socket.channel("room:lobby")
        lobbyChan?.join()
            .delegateReceive("ok", to: self, callback: { (s, m) in s.didJoinedLobby(msg: m) })
            .delegateReceive("error", to: self) { (s, m) in s.didFailJoinLobby(msg: m) }
    }
    
    private func didFailJoinLobby(msg: Message) {
        status = .failed
        print("error: failed to join lobby")
    }
    
    private func didJoinedLobby(msg: Message) {
        status = .ready
        
        print("joined to lobby")

		guard let response = msg.payload["response"] as? [String:Any] else {
			print("Got an unexpected payload from joining the lobby channel")
			return
		}

        guard let roomsDict = response["rooms"] as? [[String:Any]] else {
            print("Got an unexpected payload from joining the lobby channel")
            return
        }
        
        lobbyChan?.delegateOn("room_list", to: self) { s, m in s.onRoomList(data: m.payload) }
        lobbyChan?.delegateOn("update",    to: self) { s, m in s.onUpdateRoom(data: m.payload) }
		lobbyChan?.delegateOn("inc",       to: self) { s, m in s.onUpdateRoom(data: m.payload) }
		lobbyChan?.delegateOn("dec",       to: self) { s, m in s.onUpdateRoom(data: m.payload) }
        
        updateRooms(from: roomsDict)

    }
    
    private func onRoomList(data: Payload) {
        guard let newRooms = parseJSON([Room].self, from: data["rooms"] ?? []) else { return }
        objectWillChange.send()
        rooms = newRooms
    }

	private func onUpdateRoom(data: Payload) {
        guard let newRoom = parseJSON(Room.self, from: data) else { return }
        for (index, item) in self.rooms.enumerated() {
            if item.id == newRoom.id {
                self.rooms[index] = newRoom
                break
            }
        }
	}
    
    private func updateRooms(from dicts: [[String:Any]]) {
        guard let newRooms = parseJSON([Room].self, from: dicts) else { return }
        self.rooms = newRooms
    }
    
    private func didSocketClosed() {
    }
    
    private func didSocketErrored(error: Error) {
    }
}

fileprivate func parseJSON<T: Decodable>(_ targetType: T.Type, from payload: Any) -> T? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .fragmentsAllowed)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.customISO8601)
        
        return try! decoder.decode(targetType, from: jsonData)
    } catch {
        print("Got unexpected payload")
        return nil
    }
}


