//
//  NSDate+Coins.swift
//  Coins
//
//  Created by Sam Soffes on 11/25/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

import UIKit

extension NSDate {
	var timeAgoInWords: String {
		let intervalInSeconds = fabs(timeIntervalSinceNow)
//		let includeSeconds = true
		let intervalInMinutes = round(intervalInSeconds / 60.0)

		if intervalInMinutes >= 0 && intervalInMinutes <= 1 {
//			if !includeSeconds {
//				return intervalInMinutes <= 0 ? "less than a minute ago" : "1 minute ago"
//			}
			if intervalInSeconds >= 0 && intervalInSeconds < 10 {
				return "just now"
			} else if intervalInSeconds >= 10 && intervalInSeconds < 60 {
				return "\(Int(intervalInSeconds)) seconds ago"
			} else {
				return "1 minute ago"
			}
		} else if intervalInMinutes >= 2 && intervalInMinutes <= 44 {
			return "\(Int(intervalInMinutes)) minutes ago"
		} else if intervalInMinutes >= 45 && intervalInMinutes <= 89 {
			return "about 1 hour ago"
		} else if intervalInMinutes >= 90 && intervalInMinutes <= 1439 {
			return "\(Int(ceil(intervalInMinutes / 60.0))) hours ago"
		} else if intervalInMinutes >= 1440 && intervalInMinutes <= 2879 {
			return "1 day ago"
		} else if intervalInMinutes >= 2880 && intervalInMinutes <= 43199 {
			return "\(Int(ceil(intervalInMinutes / 1440.0))) days ago"
		} else if intervalInMinutes >= 43200 && intervalInMinutes <= 86399 {
			return "1 month ago"
		} else if intervalInMinutes >= 86400 && intervalInMinutes <= 525599 {
			return "\(Int(ceil(intervalInMinutes / 43200.0))) months ago"
		} else if intervalInMinutes >= 525600 && intervalInMinutes <= 1051199 {
			return "1 year ago"
		}

		return "\(Int(ceil(intervalInMinutes / 525600.0))) years ago"
	}
}
