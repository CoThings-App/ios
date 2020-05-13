//
//  RoomRowItem.swift
//  CoThings
//
//  Created by Neso on 2020/05/13.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI

struct RoomRowItem: View {

	var item: Room

    var body: some View {
		Text(item.name)
    }
}

struct RoomRowItem_Previews: PreviewProvider {
    static var previews: some View {
		let example: Room = Room.init(id: 1, name: "Test", count: 0, limit: 3, group: "Living Room", iBeaconUUID: nil, altBeaconUUID: nil, major: nil, minor: nil, percentage: 80, cssClass: "green", lastUpdated: "just now")
		return RoomRowItem(item: example)
    }
}
