//
//  BTCTodayValueView.m
//  Coins
//
//  Created by Sam Soffes on 9/17/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCTodayValueView.h"

@import NotificationCenter;

@interface BTCTodayValueView ()
@property (nonatomic, readonly) UIVisualEffectView *effectView;
@end

@implementation BTCTodayValueView

#pragma mark - Accessors

@synthesize effectView = _effectView;

- (UIVisualEffectView *)effectView {
	if (!_effectView) {
		_effectView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect notificationCenterVibrancyEffect]];
		_effectView.translatesAutoresizingMaskIntoConstraints = NO;
	}
	return _effectView;
}


#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
	}
	return self;
}


#pragma mark - BTCValueView

- (void)setupViews {
	self.valueButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:40.0];
	self.valueButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	[self addSubview:self.valueButton];

	[self.quantityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	self.quantityButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
	self.quantityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	[self.effectView.contentView addSubview:self.quantityButton];
	[self addSubview:self.effectView];
}


- (void)setupConstraints {
	NSDictionary *views = @{
		@"valueButton": self.valueButton,
		@"quantityView": self.quantityButton,
		@"effectView": self.effectView
	};

	CGFloat verticalSpacing = [self verticalSpacing];

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[valueButton]-8-|" options:kNilOptions metrics:nil views:views]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.valueButton attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-verticalSpacing]];

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[quantityView]|" options:kNilOptions metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[quantityView]|" options:kNilOptions metrics:nil views:views]];

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[effectView]-8-|" options:kNilOptions metrics:nil views:views]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.effectView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.valueButton attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:verticalSpacing / 2.0]];
}

@end
