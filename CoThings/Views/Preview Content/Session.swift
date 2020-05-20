//
//  Session.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/20.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import Foundation

let previewBeaconDetector = BeaconDetector()
let previewSession = PlaceSession(service: InMemoryBackend(), beaconDetector: previewBeaconDetector)
