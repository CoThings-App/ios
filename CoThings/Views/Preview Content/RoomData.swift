//
//  RoomData.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/13.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import Foundation

let ca = "Common Area"
let br = "Bathrooms"
let gb = "Garbage"
let rooms: [Room] = [
    Room(id: "1", name: "Kitchen", group: ca, population: 3, capacity: 4, lastUpdated: .ago(.minute, 3)),
    Room(id: "2", name: "Living Room", group: ca, population: 5, capacity: 4, lastUpdated: .ago(.minute, 5)),
    Room(id: "3", name: "Study Room", group: ca, population: 1, capacity: 4, lastUpdated: .ago(.hour, 2)),
    
    Room(id: "4", name: "Women", group: br, population: 1, capacity: 3, lastUpdated: .ago(.minute, 1)),
    Room(id: "5", name: "Men", group: br, population: 0, capacity: 3, lastUpdated: .ago(.minute, 8)),
    
    Room(id: "6", name: "Women", group: gb, population: 1, capacity: 3, lastUpdated: .ago(.minute, 1)),
    Room(id: "7", name: "Men", group: gb, population: 0, capacity: 3, lastUpdated: .ago(.minute, 8)),
    Room(id: "8", name: "Women", group: gb, population: 1, capacity: 3, lastUpdated: .ago(.minute, 1)),
    Room(id: "9", name: "Men", group: gb, population: 0, capacity: 3, lastUpdated: .ago(.minute, 8)),
    Room(id: "10", name: "Women", group: gb, population: 1, capacity: 3, lastUpdated: .ago(.minute, 1)),
    Room(id: "11", name: "Men", group: gb, population: 0, capacity: 3, lastUpdated: .ago(.minute, 8)),
]
