//
//  AppDelegate.swift
//  Coins
//
//  Created by Sam Soffes on 11/25/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	// MARK: - Properties

	lazy var window: UIWindow = {
		let window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window.backgroundColor = UIColor.blackColor()
		window.rootViewController = UINavigationController(rootViewController: BTCValueViewController())
		return window
	}()


	// MARK: - Private

	private func configureAppearance() {
		let navigationBar = UINavigationBar.appearance()
		navigationBar.barTintColor = CoinsKit.blueColor
		navigationBar.tintColor = UIColor(white: 1, alpha: 0.5)
		navigationBar.titleTextAttributes = [
			NSForegroundColorAttributeName: UIColor.whiteColor(),
			NSFontAttributeName: UIFont(name: "Avenir-Heavy", size: 20)!
		]
	}


	private func configureDefaults() {
		let standardDefaults = NSUserDefaults.standardUserDefaults()
		standardDefaults.registerDefaults([
			kBTCAutomaticallyRefreshKey: true,
			kBTCDisableSleepKey: false,
			kBTCControlsHiddenKey: false,
			"BTCMigrated": false
		])

		let preferences = BTCPreferences.sharedPreferences()
		preferences.registerDefaults([
			kBTCSelectedCurrencyKey: "USD",
			kBTCNumberOfCoinsKey: 0
		])

		if standardDefaults.boolForKey("BTCMigrated") {
			let keys = [kBTCSelectedCurrencyKey, kBTCNumberOfCoinsKey]
			for key in keys {
				if let value = standardDefaults.objectForKey(key) as? NSCoding {
					preferences.setObject(value, forKey: key)
				}
			}
			preferences.synchronize()

			standardDefaults.setBool(true, forKey: "BTCMigrated")
			standardDefaults.synchronize()
		}
	}


	// MARK: - UIApplicationDelegate

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
		BITHockeyManager.sharedHockeyManager().configureWithIdentifier("d0d82a50debc14c4fde0cb3430893bd6")
		BITHockeyManager.sharedHockeyManager().startManager()
		BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()

//		LLStartSession("987380b36bedad08c8468c1-1e2d6372-7443-11e3-1898-004a77f8b47f")

		application.statusBarStyle = .LightContent
		application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

		configureAppearance()
		configureDefaults()

		window.makeKeyAndVisible()

		dispatch_async(dispatch_get_main_queue()) {
			let info = NSBundle.mainBundle().infoDictionary!
			let shortVersion = (info["CFBundleShortVersionString"] as String)
			let version = (info["CFBundleVersion"] as String)
			let versionString = "\(shortVersion) (\(version))"
			let standardDefaults = NSUserDefaults.standardUserDefaults()
			standardDefaults.setObject(versionString, forKey: "BTCVersion")
			standardDefaults.synchronize()
		}

		return true
	}

	func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		BTCConversionProvider.sharedProvider().getConversionRates { conversionRate, result in
			completionHandler(result)
		}
	}
}
