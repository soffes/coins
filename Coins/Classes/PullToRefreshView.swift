//
//  PullToRefreshView.swift
//  Coins
//
//  Created by Sam Soffes on 11/26/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

import UIKit

class PullToRefreshView: SSPullToRefreshView {

	// MARK: - Initializers

	override init(scrollView: UIScrollView!, delegate: SSPullToRefreshViewDelegate!) {
		super.init(scrollView: scrollView, delegate: delegate)

		defaultContentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)

		let contentView = SSPullToRefreshSimpleContentView()
		contentView.statusLabel.textColor = UIColor(white: 1, alpha: 0.8)
		contentView.statusLabel.font = UIFont(name: "Avenir-Light", size: 12)
		contentView.activityIndicatorView.activityIndicatorViewStyle = .White
		self.contentView = contentView
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
