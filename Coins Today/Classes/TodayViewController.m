//
//  TodayViewController.m
//  Coins Today
//
//  Created by Sam Soffes on 9/17/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

#import "TodayViewController.h"
#import "CoinsKit.h"

@import NotificationCenter;

@interface TodayViewController () <NCWidgetProviding>
@end

@implementation TodayViewController

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [[BTCConversionProvider sharedProvider] getConversionRates:^(NSDictionary *conversionRates, UIBackgroundFetchResult result) {
		// TODO: Update view
		
		if (completionHandler) {
			completionHandler((NCUpdateResult)result);
		}
	}];
}

@end
