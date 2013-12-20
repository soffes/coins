//
//  BTCNavigationController.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013 Nothing Magical, Inc. All rights reserved.
//

#import "BTCNavigationController.h"

@implementation BTCNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationBar.barTintColor = [UIColor colorWithRed:0.302f green:0.235f blue:0.616f alpha:0.5f];
	self.navigationBar.tintColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
	self.navigationBar.titleTextAttributes = @{
		NSForegroundColorAttributeName: [UIColor whiteColor],
		NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:20.0f]
	};
}


- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

@end
