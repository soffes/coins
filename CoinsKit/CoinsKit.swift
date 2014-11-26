//
//  CoinsKit.swift
//  CoinsKit
//
//  Created by Sam Soffes on 11/25/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

import UIKit

public struct CoinsKit {
	public static let blueColor: UIColor = {
		return UIColor(red: 0.129, green: 0.455, blue: 0.627, alpha: 1.0)
	}()

	public static let purpleColor: UIColor = {
		return UIColor(red: 0.369, green: 0.173, blue: 0.6, alpha: 1.0)
	}()

	public static let isPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad
}

public func LocalizedString(key: String, comment: String = "") -> String {
	return NSLocalizedString(key, comment: comment)
}

public let LayoutPriorityRequired = UILayoutPriority(1000)
public let LayoutPriorityDefaultLow = UILayoutPriority(250)
