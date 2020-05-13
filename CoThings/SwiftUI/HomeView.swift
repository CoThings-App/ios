//
//  HomeView.swift
//  CoThings
//
//  Created by Neso on 2020/05/10.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI
import Foundation
import Combine

struct HomeView: View {

	@ObservedObject var socket: SocketManager = SocketManager()

	var body: some View {
		VStack {
			Text("Socket")
			Text("Beacon")
			Text("Timer")
			List {
				ForEach(self.socket.rooms, id: \.id) {room in
					RoomRowItem(item: room)
				}
			}.navigationBarTitle("Rooms")
		}
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
	}
}
