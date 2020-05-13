//
//  SocketManager.swift
//  CoThings
//
//  Created by Neso on 2020/05/13.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import Foundation
import Combine

class SocketManager: NSObject, ObservableObject {

	@Published var socketStatus: String = ""
	@Published var lastUpdatedRoom: Room? = nil
	@Published var rooms = [Room]()

	var didStatusChanged = PassthroughSubject<String, Never>()
	var didRoomUpdated = PassthroughSubject<Room, Never>()
	var didLobbyUpdated = PassthroughSubject<[Room], Never>()

	let topic = "room:lobby"

	var socket: MessageSocketAdapter? {
		didSet {
			guard let socket = socket else { return }
			setup(socket: socket)
		}
	}

	override init() {
		super.init()

		guard UserDefaults.standard.string(forKey: "serverHostname") != nil else {
			print("Socket: Host Name Not Set ")
			return
		}

		self.socket = MessageSocketAdapter(serverHostName: UserDefaults.standard.string(forKey: "serverHostname")!);

		setup(socket: self.socket!)

	}

	func setup(socket: MessageSocketAdapter) {
		listenTo(socket: socket)
		socket.connect()
		socket.joinChannel(topic: topic)
	}

	func listenTo(socket: MessageSocketAdapter) {
		socket.socketStatusChanged = {[weak self] (status) in
			guard let self = self else { return }
			switch status {
				case .socketConnecting:
					self.socketStatus = "Socket: Connecting ..."
				case .socketOpen:
					self.socketStatus = "Socket: Opened!"
				case .socketClosed:
					self.socketStatus = "Socket: Disconnected!"
				case .error(let error):
					self.socketStatus = "Socket: ERROR!: " + error.localizedDescription
				case .socketDisconnect:
					self.socketStatus = "Socket: Disconnected"
				case .channelDec:
					self.socketStatus = "Channel: Dec"
				case .channelInc:
					self.socketStatus = "Channel: Inc"
				case .channelUpdate(let channelState):
					self.socketStatus = "Channel: Update"
					if let rooms = channelState.rooms {
						self.rooms = rooms

				}
				case .roomJoin:
					self.socketStatus = "Channel: Joined the room"
				case .channelJoin(let channelState):
					if let rooms = channelState.rooms {
						self.rooms = rooms
						self.didLobbyUpdated.send(self.rooms)
				}
				case .channelPushResponse(let channelState):
					if let action = channelState.action {
						self.socketStatus =  "Socket: Sent: " + action
					}
					if let rooms = channelState.rooms {
						self.rooms = rooms
						self.didLobbyUpdated.send(self.rooms)
				}
			}
		}
	}

	func updateSocket(roomId: Int, action: MessageSocketAdapter.Action) {
		socket?.pushToChannel(topic: topic, action: action, payload: ["room_id": roomId])
	}

	func disconnectAndLeave() {
		// Be sure the leave the channel or call socket.remove(lobbyChannel)
		socket?.leaveChannel(topic: topic)
	}



}
