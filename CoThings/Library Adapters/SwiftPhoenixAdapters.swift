import SwiftPhoenixClient
import Foundation

class MessageSocketAdapter {
    
    internal enum Event {
        case socketConnecting
        case socketOpen
        case socketClosed
        case error (Error)
        case socketDisconnect
        case roomJoin([Room])
        case channelUpdate ([Room])
        case channelInc(Room)
        case channelDec(Room)
        case channelJoin ([Room])
        case channelPushResponseOk
    }
    
    internal enum Action: String {
        case dec
        case inc
    }
    
    internal enum ErrorCodes: Int {
        case channelReceive
        case socket
        case channelNotAvailable
    }
    
    // MARK: - Internal Variables
    
    internal var socketStatusChanged: ((Event) -> Void)?
    internal var openTopics: [String] {
        return Array(openTopicChannels.keys)
    }
    internal var shouldUpdate: Bool {
        guard let lastActionTime = lastActionTime else { return true }
        let elapsed = Date().timeIntervalSince(lastActionTime)
        return elapsed > 3
    }
    
    // MARK: - Private Variables
    
    private(set) var lastAction: Action?
    private var ErrorDomain: String {
        return "com.\(self.self)"
    }
    private let socket: Socket
    private var openTopicChannels = [String: Channel]()
    private var lastActionTime: Date?
    
    // MARK: - Life Cycle
    
    init(serverHostName: String) {
        socket = Socket("wss://" + serverHostName + "/socket/websocket")
        
        socket.delegateOnOpen(to: self) { (self) in
            self.socketStatusChanged?(.socketOpen)
        }
        
        socket.delegateOnClose(to: self) { (self) in
            self.socketStatusChanged?(.socketClosed)
        }
        
        socket.delegateOnError(to: self) {(self, error) in
            self.socketStatusChanged?(.error(self.createError(type: .socket,
                                                              message: error.localizedDescription)))
        }
        
        socket.disconnect { [weak self] in
            self?.socketStatusChanged?(.socketDisconnect)
        }
        
        socket.logger = { msg in print("LOG:", msg) }
    }
    
    // MARK: - Internal
    
    internal func connect() {
        self.socketStatusChanged?(.socketConnecting)
        socket.connect()
    }
    
    internal func disconnect() {
        socket.disconnect()
        openTopicChannels.removeAll()
    }
    
    internal func joinChannel(topic: String) {
        let channel = socket.channel(topic, params: ["status": "joining"])
        channel.delegateOn("join", to: self) { (self, message) in
            
            do {
                let rooms = try MessageAdapter(message: message).decodeResponse().rooms
                self.socketStatusChanged?(.roomJoin(rooms))
            } catch {
                self.socketStatusChanged?(.error(error))
            }
        }
        
        channel.delegateOn("update", to: self) { (self, message) in
            do {
                let rooms = try MessageAdapter(message: message).decodeResponse().rooms
                self.socketStatusChanged?(.channelUpdate(rooms))
            } catch {
                self.socketStatusChanged?(.error(error))
            }
        }
        
        channel.delegateOn("inc", to: self) { (self, message) in
            do {
                let room = try MessageAdapter(message: message).decodeRoomStateResponse().room
                self.socketStatusChanged?(.channelInc(room))
            } catch {
                self.socketStatusChanged?(.error(error))
            }
        }
        
        channel.delegateOn("dec", to: self) { (self, message) in
            do {
               let room = try MessageAdapter(message: message).decodeRoomStateResponse().room
               self.socketStatusChanged?(.channelDec(room))
            } catch {
               self.socketStatusChanged?(.error(error))
            }
        }
        
        channel.join().delegateReceive("ok", to: self) { (self, data) in
            do {
                let rooms = try MessageAdapter(message: data).decodeResponse().rooms
                self.socketStatusChanged?(.channelJoin(rooms))
            } catch {
                self.socketStatusChanged?(.error(error))
            }
            
        }.delegateReceive("error", to: self) { (self, message) in
            self.socketStatusChanged?(.error(self.createError(type: .channelReceive,
                                                              userInfo: message.payload)))
        }
        openTopicChannels[topic] = channel
    }
    
    internal func leaveChannel(topic: String) {
        guard let channel = openTopicChannels[topic] else { return }
        channel.leave()
        openTopicChannels.removeValue(forKey: topic)
    }
    
    internal func pushToChannel(topic: String,
                                action: Action,
                                payload: [String: Any] = [String: Any]()) {
        guard let channel = openTopicChannels[topic] else {
            self.socketStatusChanged?(.error(self.createError(type: .channelNotAvailable,
                                                              message: "topic = \(topic)")))
            return
        }
        
        channel.push(action.rawValue, payload: payload, timeout: 10).receive("ok") { (message) in
            self.socketStatusChanged?(.channelPushResponseOk)
        }.receive("error") { (errorMessage) in
            self.socketStatusChanged?(.error(self.createError(type: .channelReceive,
                                                              userInfo: errorMessage.payload)))
        }
        
        lastAction = action
        lastActionTime = Date()
    }
    
    // MARK: - Private
    
    private func createError(type: ErrorCodes, userInfo: [String: Any]) -> Error {
        return NSError(domain: self.ErrorDomain,
                       code: type.rawValue,
                       userInfo: userInfo)
    }
    
    private func createError(type: ErrorCodes, message: String) -> Error {
        return NSError(domain: self.ErrorDomain,
                       code: type.rawValue,
                       userInfo: ["info": message])
    }
}

class MessageAdapter {
    
    enum ErrorCodes: Int {
        case improperConversion
    }
    
    struct ChannelState: Decodable {
        enum CodingKeys: String, CodingKey {
            case status
            case response
        }
        
        enum ResponseKeys: String, CodingKey {
            case rooms
        }
        
        let status: String?
        let rooms: [Room]
        var action: String?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            status = try container.decodeIfPresent(String.self, forKey: .status)
            let nestedContainer = try container.nestedContainer(keyedBy: ResponseKeys.self, forKey: .response)
            rooms = try nestedContainer.decode([Room].self, forKey: .rooms)
            
            // TODO: add other state variables
        }
    }
    
    struct RoomState: Decodable {
        enum CodingKeys: String, CodingKey {
            case status
            case response
        }
        
        let status: String?
        let room: Room
        var action: String?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            status = try container.decodeIfPresent(String.self, forKey: .status)
            room = try container.decode(Room.self, forKey: .response)
        }
    }
    
    private let message: Message
    
    init(message: Message) {
        self.message = message
    }
    
    internal func decodeRoomStateResponse() throws -> RoomState {
        do {
           let jsonData = try JSONSerialization.data(withJSONObject: message.payload, options: .fragmentsAllowed)
           let decoder = JSONDecoder()
           var roomResponse = try decoder.decode(RoomState.self, from: jsonData)
           roomResponse.action = self.message.event
           return roomResponse
        } catch {
           throw NSError(domain: "com.\(self.self)", code: ErrorCodes.improperConversion.rawValue, userInfo: ["info":"\(error.localizedDescription)"])
        }
    }
    
    internal func decodeResponse() throws -> ChannelState {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message.payload, options: .fragmentsAllowed)
            let decoder = JSONDecoder()
            var roomResponse = try decoder.decode(ChannelState.self, from: jsonData)
            roomResponse.action = self.message.event
            return roomResponse
        } catch {
            throw NSError(domain: "com.\(self.self)", code: ErrorCodes.improperConversion.rawValue, userInfo: ["info":"\(error.localizedDescription)"])
        }
    }
}
