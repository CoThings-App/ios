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
		VStack(alignment: .leading, spacing: 0) {
			List {
				AboutRowView(title: "Contributors:", detail:"Who made this project?", url: URL(string: "https://cothings.app/about"))
				Divider()
				AboutRowView(title: "Source Code:", detail:"Browse the codes", url: URL(string: "https://cothings.app/"))
				Divider()
				AboutRowView(title: "Open Source Libraries:", detail:"3rd party libs", url: URL(string: "https://cothings.app/about"))
				Divider()
				AboutRowView(title: "Contact:", detail:"info@cothings.app", url: URL(string: "mailto:info@cothings.app?subject=iOS%20App"))
				Divider()
				AboutRowView(title: "Privacy", detail: "We care about it", url: URL(string: "https://\(UserDefaults.standard.string(forKey: ServerHostNameKey) ?? "")/privacy"))
				Divider()
			}.navigationBarTitle("About")
			Text(getVersionInfo())
				.font(.headline)
				.multilineTextAlignment(.trailing)
				.padding(.all, 16.0)
				.frame(maxWidth: .infinity, maxHeight: 60, alignment: .bottomTrailing)

		}
	}

	func getVersionInfo() -> String {
		return "\(Bundle.main.releaseVersionNumberPretty) (\(Bundle.main.buildVersionNumber!))"
	}

}


struct AboutView_Previews: PreviewProvider {
	static var previews: some View {
		AboutView()
	}
}
