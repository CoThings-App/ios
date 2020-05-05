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
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var locManager = CLLocationManager()
    var topic = "lobby:*"
    var timer: Timer?
    var seconds = 0
    var rooms = [Room]()
    var socket: MessageSocketAdapter? {
        didSet {
            guard let socket = socket else { return }
            setup(socket: socket)
        }
    }
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var beaconLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var lobbyTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let serverHostname = UserDefaults.standard.string(forKey: "serverHostname") else {
            self.infoLabel.text = "Socket: Host Name Not Set"
            return
        }
        
        socket = MessageSocketAdapter(serverHostName: serverHostname)
        
        lobbyTable.delegate = self
        lobbyTable.dataSource = self
        
        notificationRequest()
        locationPermissionCheck()
        
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
                self.infoLabel.text = "Socket: Connecting ..."
            case .socketOpen:
                self.infoLabel.text = "Socket: Opened!"
            case .socketClosed:
                self.infoLabel.text = "Socket: Disconnected!"
            case .error(let error):
                self.infoLabel.text = "Socket: ERROR!: " + error.localizedDescription
            case .socketDisconnect:
                self.infoLabel.text = "Socket: Disconnected"
            case .channelDec:
                self.infoLabel.text = "Channel: Dec"
            case .channelInc:
                self.infoLabel.text = "Channel: Inc"
            case .channelUpdate(let channelState):
                self.infoLabel.text = "Channel: Update"
                if let rooms = channelState.rooms {
                    self.rooms = rooms
                    self.lobbyTable.reloadData()
                }
            case .roomJoin:
                self.infoLabel.text = "Channel: Joined the room"
            case .channelJoin(let channelState):
                if let rooms = channelState.rooms {
                    self.rooms = rooms
                    self.lobbyTable.reloadData()
                }
            case .channelPushResponse(let channelState):
                if let action = channelState.action {
                    self.infoLabel.text =  "Socket: Sent: " + action
                }
                if let rooms = channelState.rooms {
                    self.rooms = rooms
                    self.lobbyTable.reloadData()
                }
            }
        }
    }
    
    private func disconnectAndLeave() {
        // Be sure the leave the channel or call socket.remove(lobbyChannel)
        socket?.leaveChannel(topic: topic)
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
        
        socket?.pushToChannel(topic: topic, action: .inc)
        
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
        
        socket?.pushToChannel(topic: topic, action: .dec)
        
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
        guard let socket = socket,
            socket.shouldUpdate else { return }
        
        switch distance {
        case .unknown, .far:
            socket.pushToChannel(topic: topic, action: .dec)
            
        case .near, .immediate:
            socket.pushToChannel(topic: topic, action: .inc)
        @unknown default:
            break
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




