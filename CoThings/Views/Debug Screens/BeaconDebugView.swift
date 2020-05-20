//
//  BeaconView.swift
//  CoThings
//
//  Created by Neso on 2020/05/13.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI
import CoreLocation

struct BeaconDebugView: View {
	@ObservedObject var beaconDetector: BeaconDetector
    @ObservedObject var roomsController: RoomsController
    
    func filteredGroups() -> [String] {
        roomsController.groups.filter({ roomsController.rooms[$0]?.contains(where: {$0.beaconIdentity != nil}) ?? false })
    }
    
    func filteredRooms(_ group: String) -> [Room] {
        roomsController.rooms[group]!.filter({ $0.beaconIdentity != nil })
    }

	var body: some View {
		return List {
            ForEach(filteredGroups(), id: \.self) { group in
                Section(header: Text(group)) {
                    ForEach(self.filteredRooms(group), id: \.self) { room in
                        VStack(alignment: .leading, spacing: 0) {
                            if room.beaconIdentity != nil {
                                self.beaconView(for: room.beaconIdentity!, room: room)
                            }
                        }
                    }.listRowInsets(EdgeInsets()).frame(minHeight: 0)
                }
            }
		}
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Beacon Debugger")
    }
    
    func beaconView(for identity: BeaconIdentity, room: Room) -> some View {
        let beacon = beaconDetector.beacons[identity]
        
        return VStack(alignment: .leading, spacing: 0) {
            if beacon != nil {
                Text("Room: \(room.name)")
                Text("Strength: \(beacon!.strength)")
                Text("Proximity: \(formatProximity(beacon!.proximity))")
                Text("Last Update: \(self.formatDate(date: room.lastUpdated))")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
        .padding(.top, 20)
        .background(
            Rectangle()
                .fill(beacon == nil ? Color.gray : Color.green)
                .cornerRadius(4)
                .frame(height: 8)
                .padding(.vertical, 16)
                .padding(.horizontal),
            alignment: .topLeading
        )
        .animation(Animation.easeIn(duration: 0.8))
    }
    
    func formatProximity(_ proximity: CLProximity) -> String {
        switch proximity {
        case .immediate:
            return "immediate"
        case .near:
            return "near"
        case .far:
            return "far"
        default:
            return "unknown"
        }
    }

	func formatDate(date: Date) -> String {
		let format = DateFormatter()
		format.dateFormat = "HH:mm:ss"
		return format.string(from: date)
	}
}
