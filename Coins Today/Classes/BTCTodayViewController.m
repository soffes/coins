//
//  BTCTodayViewController.m
//  Coins Today
//
//  Created by Sam Soffes on 9/17/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCTodayViewController.h"
#import "BTCTodayValueView.h"

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
		_valueView = [[BTCTodayValueView alloc] init];
		_valueView.translatesAutoresizingMaskIntoConstraints = NO;
		_valueView.conversionRates = [[BTCConversionProvider sharedProvider] latestConversionRates];
	}
	return _valueView;
}


#pragma mark - NSObject

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.view addSubview:self.valueView];

	NSDictionary *views = @{ @"valueView": self.valueView };
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[valueView]|" options:kNilOptions metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[valueView(120)]|" options:kNilOptions metrics:nil views:views]];

	UIControl *control = [[UIControl alloc] init];
	control.frame = self.view.bounds;
	control.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[control addTarget:self action:@selector(openCoins:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:control];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
}


- (CGSize)preferredContentSize {
	return CGSizeMake(self.view.bounds.size.width, 88.0);
}


#pragma mark - Actions

- (void)openCoins:(id)sender {
	[self.extensionContext openURL:[NSURL URLWithString:@"coins://open?ref=today"] completionHandler:nil];
}


#pragma mark - Private

- (void)update {
	self.valueView.conversionRates = [[BTCConversionProvider sharedProvider] latestConversionRates];
}


#pragma mark - NCWidgetProviding

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [[BTCConversionProvider sharedProvider] getConversionRates:^(NSDictionary *conversionRates, UIBackgroundFetchResult result) {
		[self update];
		
		if (completionHandler) {
			completionHandler((NCUpdateResult)result);
		}
	}];
}


- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
	defaultMarginInsets.top = 8.0;
	defaultMarginInsets.bottom = 8.0;
	defaultMarginInsets.left += 2.0;
	return defaultMarginInsets;
}

@end
