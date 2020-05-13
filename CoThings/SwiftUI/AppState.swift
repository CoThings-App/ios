//
//  AppState.swift
//  CoThings
//
//  Created by Neso on 2020/05/13.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
	@Published var serverHostnameIsSet: Bool = UserDefaults.standard.string(forKey: "serverHostname") != nil
}
