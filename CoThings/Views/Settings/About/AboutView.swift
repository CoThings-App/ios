//
//  AboutView.swift
//  CoThings
//
//  Created by Neso on 2020/05/29.
//  Copyright © 2020 CoThings. All rights reserved.
//

import SwiftUI

struct AboutView: View {

    private let cothingsAppBaseURL = "https://cothings.app/"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {

                AboutRowView(title: "Contributors",
                             detail:"Made by",
                             url: URL(string: "\(cothingsAppBaseURL)about"))

                AboutRowView(title: "Source Code",
                             detail:"Browse the code",
                             url: URL(string: "\(cothingsAppBaseURL)code"))

                AboutRowView(title: "Open Source Libraries",
                             detail:"3rd parties",
                             url: URL(string: "\(cothingsAppBaseURL)code"))

                AboutRowView(title: "Contact",
                             detail:"info@cothings.app",
                             url: URL(string: "mailto:info@cothings.app?subject=iOS%20App"))

                /// Each host must provide their own privacy
                /// So it should open provider's provider's privacy
                /// based on server's url
                AboutRowView(title: "Privacy",
                             detail: "Learn details",
                             url: URL(string: "https://\(UserDefaults.standard.string(forKey: ServerHostNameKey) ?? "")/privacy"))

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
