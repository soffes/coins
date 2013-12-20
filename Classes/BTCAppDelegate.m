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
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{
		kBTCSelectedCurrencyKey: @"USD",
		kBTCNumberOfCoinsKey: @0
	}];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[BTCValueViewController alloc] init]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
