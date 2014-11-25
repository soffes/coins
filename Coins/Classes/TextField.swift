//
//  TextField.swift
//  Coins
//
//  Created by Sam Soffes on 11/25/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

import UIKit

class TextField: UITextField {

	// MARK: - Initializers

	override convenience init() {
		self.init(frame: CGRectZero)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		keyboardType = .DecimalPad
		font = UIFont(name: "Avenir-Light", size: 24)
		textColor = UIColor.whiteColor()
		textAlignment = .Center
		tintColor = UIColor.whiteColor()
		backgroundColor = UIColor(white: 1, alpha: 0.1)
		layer.cornerRadius = 5

		attributedPlaceholder = NSAttributedString(string: "0", attributes: [
			NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.3),
			NSFontAttributeName: font
		])

		let suffix = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 54))
		suffix.text = "BTC"
		suffix.textColor = UIColor(white: 1, alpha: 0.3)
		suffix.font = font
		rightView = suffix
		rightViewMode = .Always
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UITextField

	override func textRectForBounds(bounds: CGRect) -> CGRect {
		return UIEdgeInsetsInsetRect(super.textRectForBounds(bounds), UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
	}

	override func editingRectForBounds(bounds: CGRect) -> CGRect {
		return textRectForBounds(bounds)
	}
}
