//
//  BTCAppDelegate.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013-2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCAppDelegate.h"
#import "BTCValueViewController.h"

@implementation BTCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	application.statusBarStyle = UIStatusBarStyleLightContent;

	UINavigationBar *navigationBar = [UINavigationBar appearance];
	navigationBar.barTintColor = [UIColor colorWithRed:0.102f green:0.451f blue:0.635f alpha:0.7f];
	navigationBar.tintColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
	navigationBar.titleTextAttributes = @{
		NSForegroundColorAttributeName: [UIColor whiteColor],
		NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:20.0f]
	};

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:@{
		kBTCSelectedCurrencyKey: @"USD",
		kBTCNumberOfCoinsKey: @0,
		kBTCAutomaticallyRefreshKey: @YES,
		kBTCDisableSleepKey: @NO,
		kBTCControlsHiddenKey: @NO
	}];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[BTCValueViewController alloc] init]];

    [self.window makeKeyAndVisible];

	dispatch_async(dispatch_get_main_queue(), ^{
		NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
		NSString *versionString = [NSString stringWithFormat:@"%@ (%@)",
								   info[@"CFBundleShortVersionString"],
								   info[@"CFBundleVersion"]];
		[userDefaults setObject:versionString forKey:@"BTCVersion"];
		[userDefaults synchronize];
	});

    return YES;
}

@end
