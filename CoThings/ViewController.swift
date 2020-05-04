//
//  ViewController.swift
//  CoThings
//
//  Created by Neso on 2020/04/17.
//  Copyright © 2020 Rainlab. All rights reserved.
//
import Foundation
import UIKit
import CoreLocation
import CoreBluetooth
import SwiftPhoenixClient
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var locManager: CLLocationManager = CLLocationManager()
    var entered = false
    var exited = false
    var lastAction: String?
    var lastActionTime: Date = Date()
    var socket: Socket?
    var topic: String = "lobby:*"
    var lobbyChannel: Channel!
    var timer: Timer?
    var seconds = 0
    var rooms = [Room]()
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var beaconLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var lobbyTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let serverHostname = UserDefaults.standard.string(forKey: "serverHostname")
        socket = Socket("wss://" + serverHostname! + "/socket/websocket")
        
        self.infoLabel.text = "Socket: Connecting ..."
        
        lobbyTable.delegate = self
        lobbyTable.dataSource = self
        
        notificationRequest()
        locationPermissionCheck()
        connectToTheSocket()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
    }
    
    @objc func fire() {
        self.seconds += 1
        self.timerLabel.text = "Timer: " + String(self.seconds) + "s"
    }
    
    func notificationRequest() {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound]
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, _) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
            }
        }
    }
    
    func locationPermissionCheck() {
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.requestAlwaysAuthorization()
        //        locManager.distanceFilter = 10;
        locManager.startUpdatingLocation()
    }
    
    func notitfy(msg: String) {
        let content = UNMutableNotificationContent() // Содержимое уведомления
        content.title = "Co-Living"
        content.body = "Action: " + msg
        content.sound = UNNotificationSound.default
    }
    
    func connectToTheSocket() {
        socket!.delegateOnOpen(to: self) { (self) in
            self.infoLabel.text = "Socket: Opened!"
        }
        
        socket!.delegateOnClose(to: self) { (self) in
            self.infoLabel.text = "Socket: Disconnected!"
        }
        
        socket!.delegateOnError(to: self) { (self, error) in
            self.infoLabel.text = "Socket: ERROR!: " + error.localizedDescription
        }
        
        socket!.logger = { msg in print("LOG:", msg) }
        
        connectAndJoin()
        
    }
    
    private func disconnectAndLeave() {
        // Be sure the leave the channel or call socket.remove(lobbyChannel)
        lobbyChannel.leave()
        socket!.disconnect {
            self.infoLabel.text = "Socket: Disconnected"
        }
    }
    
    private func connectAndJoin() {
        let channel = socket!.channel(topic, params: ["status": "joining"])
        channel.delegateOn("join", to: self) { (self, _) in
            self.infoLabel.text = "Socket: You joined the room."
        }
        
        channel.delegateOn("update", to: self) { (self, _) in
            self.infoLabel.text = "Socket: received: update"
        }
        
        channel.delegateOn("inc", to: self) { (self, _) in
            self.infoLabel.text = "Socket: received: inc"
        }
        
        channel.delegateOn("dec", to: self) { (self, _) in
            self.infoLabel.text = "Socket: received: dec"
        }
        
        self.lobbyChannel = channel
        self.lobbyChannel
            .join()
            .delegateReceive("ok", to: self) { (self, data) in
                self.infoLabel.text =  "Socket: Joined Channel"
                
                guard let response = MessageAdapter(message: data).decodeRoomResponse() else {
                    return
                }
                self.rooms = response.rooms
                self.lobbyTable.reloadData()
                
        }.delegateReceive("error", to: self) { (self, message) in
            self.infoLabel.text =  "Socket: Failed to join channel: \(message.payload)"
        }
        self.socket!.connect()
    }
    
    private func startScanning() {
        let uuid = UUID(uuidString: "")! //TODO: read this information from room.iBeacon property
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 1, minor: 10, identifier: "") //TODO: all values should come from room
        
        beaconRegion.notifyEntryStateOnDisplay = true
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locManager.startMonitoring(for: beaconRegion)
        
        //        locManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint.init(uuid: uuid, major: CLBeaconMajorValue(1), minor: CLBeaconMinorValue(10)))
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        updateSocket(action: "inc")
        
        self.seconds = 0
        
        self.beaconLabel.text = "Beacon: Found id: " + region.identifier
        
        self.view.backgroundColor = UIColor(hue: 0.241_7, saturation: 1, brightness: 0.71, alpha: 1.0) /* #63b500 */
        
        let content = UNMutableNotificationContent()
        
        content.title = "CoThings Beacon"
        content.body = "Entered"
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        let request = UNNotificationRequest(identifier: "testNotification" + String(Int.random(in: 200...300)),
                                            content: content,
                                            trigger: trigger)
        
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.add(request)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        updateSocket(action: "dec")
        
        self.seconds = 0
        
        self.beaconLabel.text = "Beacon: LOST!! id: " + region.identifier
        
        self.view.backgroundColor = UIColor(hue: 0.483_3, saturation: 0, brightness: 0.27, alpha: 1.0) /* #444444 */
        
        let content = UNMutableNotificationContent()
        
        content.title = "CoThings Beacon"
        content.body = "Exit"
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        let request = UNNotificationRequest(identifier: "testNotification" + String(Int.random(in: 200...300)),
                                            content: content,
                                            trigger: trigger)
        
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.add(request)
        
    }
    
    //    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    //        if beacons.count > 0 {
    //            updateDistance(beacons[0].proximity)
    //        } else {
    //            updateDistance(.unknown)
    //        }
    //    }
    //    
    func shouldUpdate() -> Bool {
        let elapsed = Date().timeIntervalSince(lastActionTime)
        print(elapsed)
        return elapsed > 3
    }
    
    func updateSocket(action: String) {
        //        if (self.lastAction == action) {
        //            return;
        //        }
        self.lastAction = action
        let payload = [String: Any]()
        self.lobbyChannel
            .push(action, payload: payload)
            .receive("ok") { (message) in
                print("success", message)
        }
        .receive("error") { (errorMessage) in
            print("error: ", errorMessage)
        }
        
        self.infoLabel.text =  "Socket: Sent: " + action
    }
    
    func updateDistance(_ distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                self.view.backgroundColor = UIColor.gray
            case .far:
                self.view.backgroundColor = UIColor.blue
            case .near:
                self.view.backgroundColor = UIColor.orange
            case .immediate:
                self.view.backgroundColor = UIColor.green
            @unknown default:
                self.view.backgroundColor = UIColor.red
            }
        }
        if !shouldUpdate() {
            return
        }
        lastActionTime = Date()
        switch distance {
        case .unknown:
            self.updateSocket(action: "dec")
            
        case .far:
            self.updateSocket(action: "dec")
            
        case .near:
            self.updateSocket(action: "inc")
            
        case .immediate:
            self.updateSocket(action: "inc")
        @unknown default:
            self.view.backgroundColor = UIColor.red
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        manager.stopUpdatingLocation()
        // do something with the error
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationObj = locations.last {
            if locationObj.horizontalAccuracy < 200 {
                manager.stopUpdatingLocation()
                // report location somewhere else
            }
        }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.rooms.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell: UITableViewCell = (self.lobbyTable.dequeueReusableCell(withIdentifier: "room") as UITableViewCell?)!
        
        // set the text from the data model
        cell.textLabel?.text = self.rooms[indexPath.row].name
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}



class MessageAdapter {
    
    struct RoomsResponse: Decodable {
        enum CodingKeys: String, CodingKey {
            case status
            case response
        }
        
        enum ResponseKeys: String, CodingKey {
            case rooms
        }
        
        var status: String
        var rooms: [Room]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            status = try container.decode(String.self, forKey: .status)
            let nestedContainer = try container.nestedContainer(keyedBy: ResponseKeys.self, forKey: .response)
            rooms = try nestedContainer.decode([Room].self, forKey: .rooms)
        }
    }
    
    private var message: Message
    
    init(message: Message) {
        self.message = message
    }
    
    func decodeRoomResponse() -> RoomsResponse? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message.payload, options: .fragmentsAllowed)
            let decoder = JSONDecoder()
            let roomResponse = try decoder.decode(RoomsResponse.self, from: jsonData)
            return roomResponse
        } catch {
            return nil
        }
    }
}
