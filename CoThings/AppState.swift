//
//  AppState.swift
//  CoThings
//
//  Created by Neso on 2020/05/13.
//  Copyright © 2020 CoThings. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

enum AppState {
    case initialRun
    case configurationNeeded
    case ready(session: PlaceSession)
}
