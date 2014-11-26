//
//  TableViewCell.swift
//  Coins
//
//  Created by Sam Soffes on 11/25/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

import UIKit
import CoinsKit

class TableViewCell: UITableViewCell {

	// MARK: - Initializers

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Value1, reuseIdentifier: reuseIdentifier)

		textLabel.font = UIFont(name: "Avenir-Heavy", size: 18)
		textLabel.textColor = UIColor(white: 0.4, alpha: 1)
		textLabel.highlightedTextColor = UIColor.whiteColor()
		textLabel.adjustsFontSizeToFitWidth = true

		if let detailTextLabel = detailTextLabel {
			detailTextLabel.font = UIFont(name: "Avenir-Book", size: 18)
			detailTextLabel.textColor = UIColor(white: 0.4, alpha: 0.5)
			detailTextLabel.highlightedTextColor = UIColor.whiteColor()
		}

		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
			let background = UIView()
			background.backgroundColor = UIColor(white: 1, alpha: 0.3)
			backgroundView = background
		}

		let selected = UIView()
		selected.backgroundColor = CoinsKit.blueColor
		selectedBackgroundView = selected
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func layoutSubviews() {
		super.layoutSubviews()

		var rect = textLabel.frame
		rect.size.width = min(rect.size.width, 240)
		textLabel.frame = rect

		if let detailTextLabel = detailTextLabel {
			let size = contentView.bounds.size
			detailTextLabel.frame = CGRect(x: size.width - 70, y: 10, width: 60, height: size.height - 20)
		}
	}
}
