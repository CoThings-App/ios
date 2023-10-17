//
//  DebugList.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/20.
//  Copyright © 2020 CoThings. All rights reserved.
//

import SwiftUI

struct DebugList: View {
    let session: PlaceSession

    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var roomsController: RoomsController

    init(session: PlaceSession) {
        self.session = session
        roomsController = RoomsController(session: session)
    }

    var body: some View {
        List {
            NavigationLink("Beacon Debugger",
                           destination: BeaconDebugView(
                            beaconDetector: session.beaconDetector,
                            roomsController: roomsController)
            )
        }
        .background(colorScheme == .dark ? Color.black : Color(hex: "F5F6F7"))
        .navigationBarTitle("Debug")
    }
}

struct DebugList_Previews: PreviewProvider {
    static var previews: some View {
        DebugList(session: previewSession)
    }
}
