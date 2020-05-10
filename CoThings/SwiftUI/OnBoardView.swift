//
//  OnBoardView.swift
//  CoThings
//
//  Created by Neso on 2020/05/10.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import SwiftUI

struct OnBoardView: View {
    @State var url: String = ""
    @State private var isActive: Bool = false

    var body: some View {

        NavigationView {
            VStack(alignment: .leading, spacing: 8) {

                Button(action: {}) {
                    Text("Demo")
                }

                Text("Please enter your server's url:")

                HStack(alignment: .top, spacing: 16, content: {
                    Text("https://")
                    TextField("ex: demo.cothings.app", text: $url)
                        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 1)
                })


                NavigationLink(destination: HomeView(), isActive: self.$isActive) {
                    Text("")
                }

                Button(action: {
                    self.isActive = true
                }) {
                    Text("Connect")
                }
            }
        }

    }

}

struct OnBoardView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardView()
    }
}

