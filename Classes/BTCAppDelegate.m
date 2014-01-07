//
//  BTCAppDelegate.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013-2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCAppDelegate.h"
#import "BTCValueViewController.h"
#import "LocalyticsUtilities.h"

#if ANALYTICS_ENABLED
#import <Crashlytics/Crashlytics.h>
#endif

#import "UIColor+Coins.h"

@implementation BTCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if ANALYTICS_ENABLED
	[Crashlytics startWithAPIKey:@"d719996ce2f7809259d6b116a1e5b1cf5d0f316d"];
#endif

	LLStartSession(@"987380b36bedad08c8468c1-1e2d6372-7443-11e3-1898-004a77f8b47f");

	application.statusBarStyle = UIStatusBarStyleLightContent;

	UINavigationBar *navigationBar = [UINavigationBar appearance];
	navigationBar.barTintColor = [UIColor btc_blueColor];
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
