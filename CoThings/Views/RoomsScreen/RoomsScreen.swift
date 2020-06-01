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
    @ObservedObject var roomsController: RoomsController
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.statusBarHeight) private var statusBarHeight
    
	@State private var scrollOffset: CGFloat = 0
    var rowBackground: Color {
        colorScheme == .dark ? Color(hex: "111111") : Color.white
    }
    
    var rowBorder: Color {
        colorScheme == .dark ? Color(hex: "222222") : Color(hex: "dddddd")
    }
    func sectionHeader(group: String) -> some View {
        return GroupHeaderView(title: group, occupants: roomsController.groupPopulations[group] ?? 0)
            .padding(.top)
            .background(colorScheme == .dark ? Color.black : Color(hex: "F5F6F7"))
            .edgeBorder(rowBorder, edges: .bottom)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color.black.opacity(0.4))
                .frame(height: statusBarHeight)
                .zIndex(2)
            
            GeometryReader { geom in
				PlaceHeaderView(title: self.roomsController.appConfig.title, population: 30) //FIX ME: Maybe we can show the total count of usage instead of population since we don't have such feature in backend.
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
                    .scrollOffset()
                    .onScrollOffsetChange() {
                        self.scrollOffset = $0
                    }
                
                ForEach(roomsController.groups, id: \.self) { group in
                    Section(header: self.sectionHeader(group: group)) {
						ForEach(self.roomsController.rooms[group] ?? []) { room in
                            RoomRow(room: room,
                                    onPlus: { self.roomsController.session.increasePopulation(roomID: $0.id)},
                                    onMinus: { self.roomsController.session.decreasePopulation(roomID: $0.id)})
                                .listRowInsets(EdgeInsets())
                                .frame(height: 84)
                                .padding([.leading, .trailing])
                                .background(self.rowBackground)
                                .edgeBorder(self.rowBorder, edges: .bottom)
                        }
                    }
                }
            }
            .background(colorScheme == .dark ? Color.black : Color(hex: "F5F6F7"))
            .onAppear() {
                UITableView.appearance().backgroundColor = .clear
                UITableView.appearance().separatorStyle = .none
                UITableView.appearance().sectionFooterHeight = .leastNonzeroMagnitude
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct SpacesScreen_Previews: PreviewProvider {
    static var previews: some View {
        let roomsController = RoomsController(session: previewSession)
        return Group {
			RoomsScreen(roomsController: roomsController)
                .colorScheme(.dark)
            
            RoomsScreen(roomsController: roomsController)
                .colorScheme(.light)
            
            RoomsScreen(roomsController: roomsController)
                .previewDevice("iPhone 11")
        }
    }
}
