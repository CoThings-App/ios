//
//  SpacesScreen.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/04.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import SwiftUI
import DateHelper

struct RoomsScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var placeSession: CoThingsServer
    
    @State private var scrollOffset: CGFloat = 0
    
    let roomColl: RoomCollection
    
    init(rooms: RoomCollection) {
        roomColl = rooms
    }
    
    func sectionHeader(nth: Int, group: String) -> some View {
        return GroupHeaderView(title: group, occupants: roomColl.population[group] ?? 0)
            .padding(.top)
            .background(colorScheme == .dark ? Color.black : Color(hex: "F5F6F7"))
            .edgeBorder(self.colorScheme == .dark ? Color(hex: "222222") : Color(hex: "dddddd"), edges: .bottom)
    }
    
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geom in
                PlaceHeaderView(title: "Firehouse Co-Living", population: 14)
                    .opacity(Double(geom.frame(in: .global).maxY / 125))
            }
            .frame(height: 125 + self.scrollOffset)
            .clipped()
            .edgeBorder(self.colorScheme == .dark ? Color(hex: "222222") : Color(hex: "dddddd"), edges: .bottom)
            .zIndex(1)
                    
            List {
                Spacer()
                    .frame(height: 125)
                    .listRowInsets(EdgeInsets())
                    .scrollOffset(value: $scrollOffset)
                
                
                ForEach(Array(roomColl.groups.enumerated()), id: \.1) { (i, group) in
                    Section(header: self.sectionHeader(nth: i, group: group)) {
                        ForEach(self.roomColl.rooms[group] ?? [], id: \.name) { room in
                            RoomRow(room: room)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .frame(height: 84)
                                .padding([.leading, .trailing])
                                .background(self.colorScheme == .dark ? Color(hex: "111111") : Color.white)
                                .edgeBorder(self.colorScheme == .dark ? Color(hex: "222222") : Color(hex: "dddddd"), edges: .bottom)
                        }
                    }
                }
            }
            .onScrollOffsetChange() {
                print($0)
                self.scrollOffset = $0
            }
            .onAppear() {
                UITableView.appearance().separatorStyle = .none
                UITableView.appearance().sectionFooterHeight = .leastNonzeroMagnitude
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct SpacesScreen_Previews: PreviewProvider {
    static var previews: some View {
        let coll = RoomCollection(from: rooms)
        return Group {
            RoomsScreen(rooms: coll)
                .colorScheme(.dark)
            
            RoomsScreen(rooms: coll)
                .colorScheme(.light)
            
            RoomsScreen(rooms: coll)
                .previewDevice("iPhone 11")
        }
    }
}
