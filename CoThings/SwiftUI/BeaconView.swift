//
//  BeaconView.swift
//  CoThings
//
//  Created by Neso on 2020/05/13.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI

struct BigText: ViewModifier {

	func body(content: Content) -> some View {
		content
			.font(Font.system(size: 25, design: .rounded))
//			.frame(minWidth: 0, maxWidth: .infinity, minHeight:0, maxHeight: .infinity)
//			.layoutPriority(1)
	}
}

struct BeaconView: View {

	@ObservedObject var detector: BeaconDetector = BeaconDetector()


	var body: some View {
		return VStack (alignment: .leading, spacing: 8) {
			ForEach(self.detector.rooms, id: \.self) { room in
				HStack(alignment: .top, spacing: 8) {
					Text(room.name)
					Text(room.info)
					Text(room.beaconFound ? "found" : "lost")
					Text(self.formatDate(date: room.lastUpdated))
				}
			  	.frame(minWidth: 500, maxWidth: .infinity, minHeight:100, maxHeight: 100)
				.animation(Animation.easeIn(duration: 0.8))
					.background(room.beaconFound ? Color.green : Color.gray)
			}
		}
    }

	func formatDate(date: Date) -> String {
		let format = DateFormatter()
		format.dateFormat = "HH:mm:ss"
		return format.string(from: date)
	}
}
