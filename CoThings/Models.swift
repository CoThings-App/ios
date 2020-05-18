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

struct Room: Hashable, Identifiable {
    let id: Int
    var name: String
    var group: String
    var population: Int
    var capacity: Int
    var lastUpdated: Date
    
    var altBeaconUUID: String?
    var iBeaconUUID: String?
    var major: Int?
    var minor: Int?
    
    var percentage: Int {
        Int(population / capacity * 100)
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
