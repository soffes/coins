//
//  AppDelegate.swift
//  Coins
//
//  Created by Sam Soffes on 11/25/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

import UIKit
import CoinsKit

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

	private func configureAnalytics() {
#if !DEBUG
		// Hockey
		BITHockeyManager.sharedHockeyManager().configureWithIdentifier("d0d82a50debc14c4fde0cb3430893bd6")
		BITHockeyManager.sharedHockeyManager().startManager()
		BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()

		// Mixpanel
		let mixpanel = Mixpanel.sharedInstanceWithToken("a487667944fcb1107bcaa025b3ca744c")
		mixpanel.showNetworkActivityIndicator = false
		mixpanel.track("Launch")
#endif
	}

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
		configureAnalytics()

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

	func applicationWillResignActive(application: UIApplication) {
#if !DEBUG
		Mixpanel.sharedInstance().flush()
#endif
	}
}
