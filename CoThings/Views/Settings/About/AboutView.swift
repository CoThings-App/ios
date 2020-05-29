//
//  AboutView.swift
//  CoThings
//
//  Created by Neso on 2020/05/29.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI

struct AboutView: View {
	var body: some View {
		  List {
			  AboutRowView(title: "Version:", detail:"\(Bundle.main.releaseVersionNumberPretty) (\(Bundle.main.buildVersionNumber!))")
			  Divider()
			  AboutRowView(title: "Contributors:", detail:"https://cothings.app", url: URL(string: "https://cothings.app"))
			  Divider()
			  AboutRowView(title: "Source Code:", detail:"https://cothings.app", url: URL(string: "https://cothings.app"))
				Divider()
		  }.navigationBarTitle("About")
	}
}

struct AboutView_Previews: PreviewProvider {
	static var previews: some View {
		AboutView()
	}
}
