//
//  BTCAppDelegate.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013 Nothing Magical, Inc. All rights reserved.
//

#import "BTCAppDelegate.h"
#import "BTCValueViewController.h"

@implementation BTCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	application.statusBarStyle = UIStatusBarStyleLightContent;

	UINavigationBar *navigationBar = [UINavigationBar appearance];
	navigationBar.barTintColor = [UIColor colorWithRed:0.302f green:0.235f blue:0.616f alpha:0.5f];
	navigationBar.tintColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
	navigationBar.titleTextAttributes = @{
		NSForegroundColorAttributeName: [UIColor whiteColor],
		NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:20.0f]
	};

	[[NSUserDefaults standardUserDefaults] registerDefaults:@{
		kBTCSelectedCurrencyKey: @"USD",
		kBTCNumberOfCoinsKey: @0,
		kBTCAutomaticallyRefreshKey: @YES,
		kBTCDisableSleepKey: @NO
	}];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[BTCValueViewController alloc] init]];

    [self.window makeKeyAndVisible];
    return YES;
}

@end
