//
//  GroupHeaderView.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/04.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import SwiftUI

struct GroupHeaderView: View {
    let title: String
    let occupants: Int
    
    static let titleFont = Font.custom("Avenir Next", size: 18).bold()
    static let occupantsFont = Font.custom("SF Pro Text", size: 14)
    
    var body: some View {
        VStack(alignment: .leading, spacing: -3) {
            Text(title.uppercased())
                .font(GroupHeaderView.titleFont)
                .foregroundColor(.primary)
            
            Text("\(occupants) occupants are present")
                .font(GroupHeaderView.occupantsFont)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowInsets(EdgeInsets())
    }
}

struct GroupHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section(header: GroupHeaderView(title: "Common Area", occupants: 9).background(Color.red)) {
                Text("List Item")
            }
        }.listStyle(GroupedListStyle())
        .onAppear() {
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().tableFooterView = nil
        }
    }
}
