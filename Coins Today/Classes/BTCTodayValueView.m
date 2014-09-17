//
//  BTCTodayValueView.m
//  Coins
//
//  Created by Sam Soffes on 9/17/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCTodayValueView.h"

@implementation BTCTodayValueView

- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;

		self.valueButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:40.0];
		self.valueButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

		self.quantityButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
		self.quantityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	}
	return self;
}


//- (CGFloat)verticalSpacing {
//	return -8.0;
//}

@end
