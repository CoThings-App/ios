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

	var body: some View {
		VStack {
			Text("Socket")
			Text("Beacon")
			Text("Timer")
			List {
				Section(header: Text("Living Room"))
				{
					Text("Kitchen")
					Text("Cooking")
				}

				Section(header: Text("Bathrooms")) {
					Text("Women")
					Text("Men")
				}


				Section(header: Text("Washing Machines")) {
					Text("Women")
					Text("Men")
				}


				Section(header: Text("Dryers")) {
					Text("Women")
					Text("Men")
				}

			}
	}
}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
	}
}
