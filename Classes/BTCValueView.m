//
//  BTCValueView.m
//  Coins
//
//  Created by Sam Soffes on 4/23/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCValueView.h"
#import "UIColor+Coins.h"

@implementation BTCValueView

#pragma mark - Accessors

@synthesize valueButton = _valueButton;
@synthesize inputButton = _inputButton;

- (UIButton *)valueButton {
	if (!_valueButton) {
		_valueButton = [[UIButton alloc] init];
		_valueButton.translatesAutoresizingMaskIntoConstraints = NO;
		_valueButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80.0f : 50.0f];
		_valueButton.titleLabel.adjustsFontSizeToFitWidth = YES;
		_valueButton.titleLabel.textAlignment = NSTextAlignmentCenter;
		[_valueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	return _valueButton;
}


- (UIButton *)inputButton {
	if (!_inputButton) {
		_inputButton = [[UIButton alloc] init];
		_inputButton.translatesAutoresizingMaskIntoConstraints = NO;
		_inputButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 30.0f : 20.0f];
		[_inputButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateNormal];
	}
	return _inputButton;
}


#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.translatesAutoresizingMaskIntoConstraints = NO;
		self.backgroundColor = [UIColor clearColor];
		self.gradientColors = @[
			[UIColor btc_blueColor],
			[UIColor btc_purpleColor]
		];
		self.dimmedGradientColors = self.gradientColors;

		
		[self addSubview:self.valueButton];
		[self addSubview:self.inputButton];

		[self setupConstraints];
	}
	return self;
}


#pragma mark - Private

- (void)setupConstraints {
	NSDictionary *views = @{
		@"valueButton": self.valueButton,
		@"inputButton": self.inputButton
	};

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[valueButton]-|" options:kNilOptions metrics:nil views:views]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.valueButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-20.0]];

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[inputButton]-|" options:kNilOptions metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[valueButton]-(-15)-[inputButton]" options:kNilOptions metrics:nil views:views]];
}

@end
