//
//  BTCTextField.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013 Nothing Magical, Inc. All rights reserved.
//

#import "BTCTextField.h"

#import <QuartzCore/QuartzCore.h>

@implementation BTCTextField

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.keyboardType = UIKeyboardTypeDecimalPad;
		self.text = [[NSUserDefaults standardUserDefaults] stringForKey:kBTCNumberOfCoinsKey];
		self.font = [UIFont fontWithName:@"Avenir-Light" size:24.0f];
		self.textColor = [UIColor whiteColor];
		self.textAlignment = NSTextAlignmentCenter;
		self.tintColor = [UIColor whiteColor];
		self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
		self.layer.cornerRadius = 5.0f;

		UILabel *suffix = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 54.0f)];
		suffix.text = @"BTC";
		suffix.textColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
		suffix.font = self.font;
		self.rightView = suffix;
		self.rightViewMode = UITextFieldViewModeAlways;
	}
	return self;
}


- (CGRect)textRectForBounds:(CGRect)bounds {
	return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f));
}


- (CGRect)editingRectForBounds:(CGRect)bounds {
	return [self textRectForBounds:bounds];
}

@end
