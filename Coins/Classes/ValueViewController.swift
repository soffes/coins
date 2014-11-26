//
//  ValueViewController.swift
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013-2014 Nothing Magical, Inc. All rights reserved.
//

import UIKit
import CoinsKit
import GradientView

class BTCValueViewController: UIViewController, UITextFieldDelegate, SSPullToRefreshViewDelegate {

	// MARK: - Properties

	let flapsView: GradientView = {
		let view = GradientView()
		view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
		view.colors = [CoinsKit.blueColor, CoinsKit.purpleColor]
		view.locations = [0.5, 0.51]
		return view
	}()

	let scrollView: UIScrollView = {
		let view = UIScrollView()
		view.setTranslatesAutoresizingMaskIntoConstraints(false)
		view.showsHorizontalScrollIndicator = false
		view.showsVerticalScrollIndicator = false
		view.alwaysBounceVertical = true
		return view
	}()

	var pullToRefresh: SSPullToRefreshView!

	let backgroundView: GradientView = {
		let view = GradientView()
		view.setTranslatesAutoresizingMaskIntoConstraints(false)
		view.colors = [CoinsKit.blueColor, CoinsKit.purpleColor]
		return view
	}()

	let valueView = BTCValueView()

	let updateButton: TickingButton = {
		let view = TickingButton()
		view.setTranslatesAutoresizingMaskIntoConstraints(false)
		view.setTitleColor(UIColor(white: 1, alpha: 0.3), forState: .Normal)
		view.setTitleColor(UIColor(white: 1, alpha: 0.8), forState: .Highlighted)
		view.titleLabel?.font = UIFont(name: "Avenir-Light", size: 12)
		view.titleLabel?.textAlignment = .Center
		return view
	}()

	let textField: TextField = {
		let view = TextField()
		view.setTranslatesAutoresizingMaskIntoConstraints(false)
		view.alpha = 0
		return view
	}()

	let doneButton: UIButton = {
		let view = UIButton()
		view.setTranslatesAutoresizingMaskIntoConstraints(false)
		view.titleLabel?.font = UIFont(name: "Avenir-Light", size: 14)
		view.alpha = 0
		view.setTitleColor(UIColor(white: 1, alpha: 0.5), forState: .Normal)
		view.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
		view.setTitle(LocalizedString("DONE"), forState: .Normal)
		view.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		view.layer.borderColor = UIColor(white: 1, alpha: 0.5).CGColor
		view.layer.borderWidth = 1
		view.layer.cornerRadius = 5
		return view
	}()

	var currencyPopover: UIPopoverController?

	var controlsHidden: Bool = false

	var loading: Bool = false {
		didSet {
			UIApplication.sharedApplication().networkActivityIndicatorVisible = loading

			if loading {
				updateButton.format = LocalizedString("UPDATING")
				pullToRefresh.startLoading()
			} else {
				updateButton.format = LocalizedString("UPDATED_FORMAT")
				pullToRefresh.finishLoading()
			}
		}
	}

	var autoRefreshing: Bool = false {
		didSet {
			if autoRefreshing && autoRefreshTimer == nil {
				let timer = NSTimer(timeInterval: 60, target: self, selector: "refresh:", userInfo: nil, repeats: true)
				NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
				autoRefreshTimer = timer
			} else {
				autoRefreshTimer?.invalidate()
			}
		}
	}

	var autoRefreshTimer: NSTimer?

	var doneButtonTopConstraint: NSLayoutConstraint!

	var textFieldTopConstraint: NSLayoutConstraint!

	var keyboardFrame: CGRect = CGRectZero


	// MARK: - Initializers

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		automaticallyAdjustsScrollViewInsets = false
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

		textField.delegate = self
		doneButton.addTarget(self, action: "toggleControls", forControlEvents: .TouchUpInside)
		valueView.valueButton.addTarget(self, action: "pickCurrency", forControlEvents: .TouchUpInside)
		valueView.quantityButton.addTarget(self, action: "startEditing", forControlEvents: .TouchUpInside)
		updateButton.addTarget(self, action: "refresh", forControlEvents: .TouchUpInside)

		flapsView.frame = view.bounds
		view.addSubview(flapsView)

		view.addSubview(scrollView)
		self.pullToRefresh = PullToRefreshView(scrollView: scrollView, delegate: self)

		scrollView.addSubview(backgroundView)
		backgroundView.addSubview(valueView)
		view.addSubview(updateButton)
		view.addSubview(textField)
		view.addSubview(doneButton)

		setupViewConstraints()

		let tap = UITapGestureRecognizer(target: self, action: "toggleControls")
		scrollView.addGestureRecognizer(tap)

		let notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.addObserver(self, selector: "textFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: nil)
		notificationCenter.addObserver(self, selector: "updateTimerPaused", name: UIApplicationDidEnterBackgroundNotification, object: nil)
		notificationCenter.addObserver(self, selector: "updateTimerPaused", name: UIApplicationDidBecomeActiveNotification, object: nil)
		notificationCenter.addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)

		notificationCenter.addObserver(self, selector: "update", name: kBTCCurrencyDidChangeNotificationName, object: nil)
		notificationCenter.addObserver(self, selector: "update", name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: nil)
		update()

		notificationCenter.addObserver(self, selector: "refresh", name: UIApplicationDidBecomeActiveNotification, object: nil)
		refresh()

		notificationCenter.addObserver(self, selector: "preferencesDidChange", name: NSUserDefaultsDidChangeNotification, object: nil)
		preferencesDidChange()

		setControlsHidden(NSUserDefaults.standardUserDefaults().boolForKey(kBTCControlsHiddenKey), animated: false)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		update()
		navigationController?.setNavigationBarHidden(true, animated: animated)

		updateButton.startTicking()
		autoRefreshing = NSUserDefaults.standardUserDefaults().boolForKey(kBTCAutomaticallyRefreshKey)

		if BTCPreferences.sharedPreferences().doubleForKey(kBTCNumberOfCoinsKey) == 0.0 {
			setEditing(true, animated: animated)
		}
	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		updateButton.stopTicking()
		autoRefreshing = false
	}

	override func setEditing(editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		if editing {
			view.addConstraint(doneButtonTopConstraint)
			view.addConstraint(textFieldTopConstraint)
			textField.becomeFirstResponder()
		} else {
			view.removeConstraint(doneButtonTopConstraint)
			view.removeConstraint(textFieldTopConstraint)
			textField.resignFirstResponder()
			BTCPreferences.sharedPreferences().synchronize()
		}

		let animations: () -> Void = {
			self.textField.alpha = editing ? 1 : 0
			self.doneButton.alpha = self.textField.alpha
			self.valueView.valueButton.alpha = editing ? 0.0 : 1.0
			self.valueView.quantityButton.alpha = self.valueView.valueButton.alpha
		}

		if (animated) {
			UIView.animateWithDuration(0.3, animations: animations)
			UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: nil, animations: { () -> Void in
				self.view.layoutIfNeeded()
			}, completion: nil)
		} else {
			animations()
		}
	}


	override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
		super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)

		currencyPopover?.dismissPopoverAnimated(true)
		updateDoneButtonTopLayoutConstraint()
	}


	// MARK - Actions

	func refresh() {
		if loading {
			return
		}

		loading = true

		BTCConversionProvider.sharedProvider().getConversionRates() { conversionRates, result in
			self.update()
			self.loading = false
		}
	}

	func pickCurrency() {
		let viewController = CurrencyPickerTableViewController()

		if CoinsKit.isPad {
			let navigationController = UINavigationController(rootViewController: viewController)
			let popover = UIPopoverController(contentViewController: navigationController)
			popover.presentPopoverFromRect(valueView.valueButton.frame, inView: view, permittedArrowDirections: .Down, animated: true)
			self.currencyPopover = popover
			return
		}
	
		self.navigationController?.pushViewController(viewController, animated: true)
	}

	func toggleControls() {
		if editing {
			setEditing(false, animated: true)
			return
		}

		setControlsHidden(!controlsHidden, animated: true)
	}

	func startEditing() {
		setEditing(true, animated: true)
	}


	// MARK: - Private

	private func setupViewConstraints() {
		doneButtonTopConstraint = NSLayoutConstraint(item: doneButton, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
		doneButtonTopConstraint.priority = LayoutPriorityRequired
		updateDoneButtonTopLayoutConstraint()

		textFieldTopConstraint = NSLayoutConstraint(item: textField, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
		textFieldTopConstraint.priority = LayoutPriorityRequired

		let views = [
			"scrollView": scrollView,
			"backgroundView": backgroundView,
			"valueView": valueView,
			"updateButton": updateButton,
			"textField": textField,
			"doneButton": doneButton
		]

		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[scrollView]|", options: nil, metrics: nil, views: views))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: nil, metrics: nil, views: views))

		var attributes: [NSLayoutAttribute] = [.Top, .Left, .Bottom, .Right]
		for attribute in attributes {
			view.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
			view.addConstraint(NSLayoutConstraint(item: valueView, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
		}

		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[updateButton]-|", options: nil, metrics: nil, views: views))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[updateButton]-10-|", options: nil, metrics: nil, views: views))

		let doneBottomConstraint = NSLayoutConstraint(item: doneButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
		doneBottomConstraint.priority = LayoutPriorityDefaultLow
		view.addConstraint(doneBottomConstraint)

		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[doneButton]-|", options: nil, metrics: nil, views: views))

		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(20@500)-[textField(<=500@600)]-(20@500)-|", options: nil, metrics: nil, views: views))

		let weakTextFieldTopConstraint = NSLayoutConstraint(item: textField, attribute: .Top, relatedBy: .Equal, toItem: valueView.valueButton, attribute: .Bottom, multiplier: 1, constant: 0)
		weakTextFieldTopConstraint.priority = LayoutPriorityDefaultLow
		view.addConstraint(weakTextFieldTopConstraint)

		view.addConstraint(NSLayoutConstraint(item: textField, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))

		let requiredTextFieldTopConstraint = NSLayoutConstraint(item: textField, attribute: .Top, relatedBy: .GreaterThanOrEqual, toItem: doneButton, attribute: .Bottom, multiplier: 1, constant: 20)
		requiredTextFieldTopConstraint.priority = LayoutPriorityRequired
		view.addConstraint(requiredTextFieldTopConstraint)
	}

	func textFieldDidChange(notification: NSNotification?) {
		var string = textField.text ?? ""
		string = string.stringByReplacingOccurrencesOfString(",", withString: ".")

		let preferences = BTCPreferences.sharedPreferences()
		preferences.setObject(strtod(string, nil), forKey: kBTCNumberOfCoinsKey)
		preferences.synchronize()

		update()
	}

	func update() {
		if CoinsKit.isPad {
			currencyPopover?.dismissPopoverAnimated(true)
		}

		if let conversionRates = BTCConversionProvider.sharedProvider().latestConversionRates() {
			updateButton.date = conversionRates["updatedAt"] as? NSDate
			valueView.conversionRates = conversionRates
		}

		if !textField.editing {
			let number = BTCPreferences.sharedPreferences().objectForKey(kBTCNumberOfCoinsKey).description
			textField.text = number == "0" ? nil : number
		}
	}

	func preferencesDidChange() {
		UIApplication.sharedApplication().idleTimerDisabled = NSUserDefaults.standardUserDefaults().boolForKey(kBTCDisableSleepKey)
		updateTimerPaused()
	}

	private func setControlsHidden(controlsHidden: Bool, animated: Bool) {
		let application = UIApplication.sharedApplication()
		let statusBarAnimation: UIStatusBarAnimation = animated ? .Fade : .None

		if self.controlsHidden == controlsHidden {
			if application.statusBarHidden != controlsHidden {
				application.setStatusBarHidden(controlsHidden, withAnimation: statusBarAnimation)
			}
			return
		}

		self.controlsHidden = controlsHidden

		application.setStatusBarHidden(controlsHidden, withAnimation: statusBarAnimation)
		updateDoneButtonTopLayoutConstraint()

		let userDefaults = NSUserDefaults.standardUserDefaults()
		userDefaults.setBool(controlsHidden, forKey: kBTCControlsHiddenKey)
		userDefaults.synchronize()

		let animations: () -> Void = {
			self.updateButton.alpha = controlsHidden ? 0 : 1
			self.view.layoutIfNeeded()
		}

		if animated {
			UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .AllowUserInteraction, animations: animations, completion: nil)
		} else {
			animations()
		}
	}

	func updateTimerPaused() {
		let isActive = UIApplication.sharedApplication().applicationState == .Active
		autoRefreshing = isActive && NSUserDefaults.standardUserDefaults().boolForKey(kBTCAutomaticallyRefreshKey)
	}

	func keyboardWillChangeFrame(notification: NSNotification?) {
		if let value = notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
			keyboardFrame = value.CGRectValue()
			textFieldTopConstraint.constant = min(keyboardFrame.size.height, keyboardFrame.size.width) / -2.0
		}
	}

	private func updateDoneButtonTopLayoutConstraint() {
		var constant: CGFloat = 10.0

		if !controlsHidden {
			constant += 20.0
		}

		if CoinsKit.isPad || UIInterfaceOrientationIsPortrait(self.interfaceOrientation) {
			constant += 6.0
		}
	
		doneButtonTopConstraint.constant = constant
	}


	// MARK: - UITextFieldDelegate

	func textFieldShouldReturn(textField: UITextField) -> Bool {
		toggleControls()
		return false
	}

	func textFieldDidEndEditing(textField: UITextField) {
		if editing {
			setEditing(false, animated: true)
		}
	}


	// MARK: - SSPullToRefreshViewDelegate

	func pullToRefreshViewDidStartLoading(view: SSPullToRefreshView!) {
		refresh()
	}

	func pullToRefreshViewShouldStartLoading(view: SSPullToRefreshView!) -> Bool {
		return !loading && !editing
	}
}
