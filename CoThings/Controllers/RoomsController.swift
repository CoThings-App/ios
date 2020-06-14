//
//  RoomsController.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/15.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import Foundation
import Combine

class RoomsController: ObservableObject, APIRequestDelegate {
    let session: PlaceSession
    
    @Published var rooms: [String: [Room]] = [:]
    @Published var groups: [String] = []
    @Published var groupPopulations: [String: Int] = [:]
    @Published var isLoading: Bool = false
    
    private var roomsSubscription: AnyCancellable!

	var appConfig = AppConfig(title: "CoThings",  imageUrl: "")

    init(session: PlaceSession) {
        self.session = session
        
        isLoading = true
        roomsSubscription = session.$rooms
            .sink { rooms in
                let sortedRooms = rooms.sorted {$0.name < $1.name}
                self.rooms = Dictionary(grouping: sortedRooms, by: { $0.group })
                
                self.groups = NSOrderedSet(array: rooms.map(\.group), copyItems: true).array as! [String]
                
                var groupPopulations = [String: Int]()
                for group in self.groups {
                    let population = self.rooms[group]!.reduce(0, {$0 + $1.population})
                    groupPopulations[group] = population
                }
                
                self.groupPopulations = groupPopulations
                
                self.isLoading = false
            }

		getAppConfig()
    }

	func getAppConfig() {
		APIRequest<AppConfig>.get(self, relativeUrl: "config.json", jsonKey: "app", success: { config in
			self.appConfig = config
		})
	}

	func onError(_ message: String) {
		print("API Request got error: " + message)
	}


}
