//
//  TickingButton.swift
//  Coins
//
//  Created by Sam Soffes on 11/25/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

import UIKit

class TickingButton: UIButton {

//	@property (nonatomic, readwrite, getter = isTicking) BOOL ticking;
//	@property (nonatomic) NSTimer *timer;
//	@property (nonatomic) NSDate *date;
//	@property (nonatomic) NSString *format;
//
//	- (void)startTicking;
//	- (void)stopTicking;

	// MARK: - Properties

	var ticking = false

	var date: NSDate? {
		didSet {
			tick()
		}
	}

	var format: String = "" {
		didSet {
			tick()
		}
	}

	var timer: NSTimer?


	// MARK: - Public

	func startTicking() {
		ticking = true
		let timer = NSTimer(timeInterval: 1, target: self, selector: "tick", userInfo: nil, repeats: true)
		NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
		self.timer = timer
	}

	func stopTicking() {
		if !ticking {
			return
		}

		ticking = false
		timer?.invalidate()
		timer = nil
	}

	func tick() {
		var title = LocalizedString("NEVER_UPDATED")
		if let date = date {
			// This is gross
			title = (format as NSString).stringByReplacingOccurrencesOfString("%@", withString: date.timeAgoInWords)
		}
		setTitle(title, forState: .Normal)
	}
}
