//
//  CurrencyPickerTableViewController.swift
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013-2014 Nothing Magical, Inc. All rights reserved.
//

import UIKit

class CurrencyPickerTableViewController: UITableViewController {

	// MARK: - Properties

	let currencies: [String: String]
	let order: [String]
	var selectedKey: String = BTCPreferences.sharedPreferences().objectForKey(kBTCSelectedCurrencyKey) as String


	// MARK: - Initializers

	override convenience init() {
		self.init(nibName: nil, bundle: nil)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		let path = NSBundle.mainBundle().pathForResource("currencies", ofType: "json")!
		let data = NSData(contentsOfFile: path)!
		let JSON = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as [String: AnyObject]
		currencies = JSON["currencies"] as [String: String]
		order = JSON["order"] as [String]

		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		title = LocalizedString("CURRENCY")

		tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "Cell")
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		if let index = find(order, selectedKey) {
			let indexPath = NSIndexPath(forRow: index, inSection: 0)
			tableView.selectRowAtIndexPath(indexPath, animated: animated, scrollPosition: .Middle)
		}

		navigationController?.setNavigationBarHidden(false, animated: animated)
	}


	// MARK: - UITableViewDataSource

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return countElements(order)
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as TableViewCell
		cell.selectionStyle = .Blue

		let key = order[indexPath.row]

		cell.textLabel?.text = currencies[key]
		cell.detailTextLabel?.text = key

		return cell
	}


	// MARK: - UITableViewDelegate

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let key = order[indexPath.row]
		let preferences = BTCPreferences.sharedPreferences()
		preferences.setObject(key, forKey: kBTCSelectedCurrencyKey)
		preferences.synchronize()

		NSNotificationCenter.defaultCenter().postNotificationName(kBTCCurrencyDidChangeNotificationName, object: key)
		navigationController?.popViewControllerAnimated(true)
	}
}
