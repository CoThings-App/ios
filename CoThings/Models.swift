//
//  Models.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/04.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import Foundation

let ServerHostNameKey = "serverHostname"
let PassOnboardingKey = "passOnboarding"
let RoomStatusesKey = "roomStatuses"

struct Room: Identifiable {
    let id: Int
    var name: String
    var group: String
    var population: Int
    var capacity: Int
    var lastUpdated: Date
    
    var altBeaconUUID: String?
    var iBeaconUUID: UUID?
    var major: Int?
    var minor: Int?
    
    var percentage: Int {
        Int(population / capacity * 100)
    }
}

extension Room: Hashable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(iBeaconUUID)
        hasher.combine(major)
        hasher.combine(minor)
    }
}

extension Room: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case population = "count"
        case capacity
        case group
        case altBeaconUUID = "altbeacon_uuid"
        case iBeaconUUID = "ibeacon_uuid"
        case major
        case minor
        case lastUpdated = "updated_at"
    }
}
