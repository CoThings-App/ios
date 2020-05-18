//
//  Date+Ago.swift
//  CoThings
//
//  Created by Umur Gedik on 2020/05/04.
//  Copyright © 2020 Umur Gedik. All rights reserved.
//

import Foundation
import DateHelper

extension Date {
    static func ago(_ component: DateComponentType, _ offset: Int) -> Date {
        return Date().adjust(component, offset: -offset)
    }
}
