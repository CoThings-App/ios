//
//  CoHostingController.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/06.
//  Copyright © 2020 CoThings. All rights reserved.
//

import SwiftUI

class CoHostingController<Content: View>: UIHostingController<Content> {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

