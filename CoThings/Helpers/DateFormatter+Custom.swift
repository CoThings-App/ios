//
//  Date+JSONFormatter.swift
//  CoThings
//
//  Created by Neso on 2020/05/15.
//  Copyright © 2020 Rainlab. All rights reserved.
//

import Foundation


extension DateFormatter {
	static let customISO8601: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()
}
