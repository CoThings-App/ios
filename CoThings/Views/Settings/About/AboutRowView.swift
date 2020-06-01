//
//  AboutRowView.swift
//  CoThings
//
//  Created by Neso on 2020/05/29.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI

struct AboutRowView: View {

	let title: String
	let detail: String
	var url: URL? = nil

    var body: some View {
		HStack(alignment: .center, spacing: 16, content: {
			Text(title)
				.font(.headline)
			Spacer(minLength: 30)
			if (self.url != nil) {
				Button(action: {
					guard let urlToOpen = self.url else { return }
					UIApplication.shared.open(urlToOpen)
				})
				{
					Text(detail)
						.foregroundColor(Color.blue)
				}
			} else {
				Text(detail)
					.font(.subheadline)
			}
			}).frame(minWidth: 320, maxWidth: .infinity)
    }
}

struct AboutRowView_Previews: PreviewProvider {
    static var previews: some View {
		AboutRowView(title: "Version", detail: "v1.0.0")
    }
}
