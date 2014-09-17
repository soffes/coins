//
//  BTCTodayViewController.m
//  Coins Today
//
//  Created by Sam Soffes on 9/17/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCTodayViewController.h"
#import "CoinsKit.h"

@import NotificationCenter;

@interface BTCTodayViewController () <NCWidgetProviding>
@property (nonatomic, readonly) BTCValueView *valueView;
@end

@implementation BTCTodayViewController

#pragma mark - Accessors

@synthesize valueView = _valueView;

- (BTCValueView *)valueView {
	if (!_valueView) {
		_valueView = [[BTCValueView alloc] init];
		_valueView.translatesAutoresizingMaskIntoConstraints = NO;
		_valueView.conversionRates = [[BTCConversionProvider sharedProvider] latestConversionRates];
	}
	return _valueView;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.view addSubview:self.valueView];

	NSDictionary *views = @{ @"valueView": self.valueView };
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[valueView]|" options:kNilOptions metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[valueView(120)]|" options:kNilOptions metrics:nil views:views]];
}


#pragma mark - NCWidgetProviding

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [[BTCConversionProvider sharedProvider] getConversionRates:^(NSDictionary *conversionRates, UIBackgroundFetchResult result) {
		self.valueView.conversionRates = conversionRates;
		
		if (completionHandler) {
			completionHandler((NCUpdateResult)result);
		}
	}];
}


- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
	defaultMarginInsets.top = 8.0;
	defaultMarginInsets.bottom = 0.0;
	return defaultMarginInsets;
}

@end
