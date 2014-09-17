//
//  BTCValueView.m
//  Coins
//
//  Created by Sam Soffes on 4/23/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCValueView.h"
#import "BTCDefines.h"

#import "UIColor+Coins.h"
#import "NSUserDefaults+Coins.h"

@implementation BTCValueView

#pragma mark - Accessors

@synthesize conversionRates = _conversionRates;
@synthesize valueButton = _valueButton;
@synthesize quantityButton = _quantityButton;

- (void)setConversionRates:(NSDictionary *)conversionRates {
	_conversionRates = conversionRates;

	static NSNumberFormatter *currencyFormatter = nil;
	static dispatch_once_t currencyOnceToken;
	dispatch_once(&currencyOnceToken, ^{
		currencyFormatter = [[NSNumberFormatter alloc] init];
		currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
	});

	NSUserDefaults *userDefaults = [NSUserDefaults btc_sharedDefaults];
	currencyFormatter.currencyCode = [userDefaults stringForKey:kBTCSelectedCurrencyKey];
	double value = [userDefaults doubleForKey:kBTCNumberOfCoinsKey] * [conversionRates[currencyFormatter.currencyCode] doubleValue];
	[self.valueButton setTitle:[currencyFormatter stringFromNumber:@(value)] forState:UIControlStateNormal];

	static NSNumberFormatter *numberFormatter = nil;
	static dispatch_once_t numberOnceToken;
	dispatch_once(&numberOnceToken, ^{
		numberFormatter = [[NSNumberFormatter alloc] init];
		numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
		numberFormatter.currencySymbol = @"";
		numberFormatter.minimumFractionDigits = 0;
		numberFormatter.maximumFractionDigits = 10;
		numberFormatter.roundingMode = NSNumberFormatterRoundDown;
	});

	// Ensure it's a double for backwards compatibility with 1.0
	NSNumber *number = @([[userDefaults stringForKey:kBTCNumberOfCoinsKey] doubleValue]);

	NSString *title = [numberFormatter stringFromNumber:number];
	[self.quantityButton setTitle:[NSString stringWithFormat:@"%@ BTC", title] forState:UIControlStateNormal];
}

- (UIButton *)valueButton {
	if (!_valueButton) {
		_valueButton = [[UIButton alloc] init];
		_valueButton.translatesAutoresizingMaskIntoConstraints = NO;
		_valueButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80.0 : 50.0];
		_valueButton.titleLabel.adjustsFontSizeToFitWidth = YES;
		_valueButton.titleLabel.textAlignment = NSTextAlignmentCenter;
		[_valueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	return _valueButton;
}


- (UIButton *)quantityButton {
	if (!_quantityButton) {
		_quantityButton = [[UIButton alloc] init];
		_quantityButton.translatesAutoresizingMaskIntoConstraints = NO;
		_quantityButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 30.0 : 20.0];
		[_quantityButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5f] forState:UIControlStateNormal];
	}
	return _quantityButton;
}


#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.translatesAutoresizingMaskIntoConstraints = NO;
		self.backgroundColor = [UIColor clearColor];

		[self setupViews];
		[self setupConstraints];
	}
	return self;
}


#pragma mark - Configuration

- (CGFloat)verticalSpacing {
	return 16.0;
}


- (void)setupViews {
	[self addSubview:self.valueButton];
	[self addSubview:self.quantityButton];
}


#pragma mark - Private

- (void)setupConstraints {
	NSDictionary *views = @{
		@"valueButton": self.valueButton,
		@"quantityView": self.quantityButton
	};

	CGFloat verticalSpacing = [self verticalSpacing];

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[valueButton]-|" options:kNilOptions metrics:nil views:views]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.valueButton attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-verticalSpacing]];

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[quantityView]-|" options:kNilOptions metrics:nil views:views]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.quantityButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.valueButton attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:verticalSpacing / 2.0]];
}

@end
