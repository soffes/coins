//
//  BTCTableViewCell.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013 Nothing Magical, Inc. All rights reserved.
//

#import "BTCTableViewCell.h"

@implementation BTCTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])) {
		self.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:18.0f];
//		self.textLabel.textColor = [UIColor shr_darkTextColor];
		self.textLabel.highlightedTextColor = [UIColor whiteColor];
		self.textLabel.adjustsFontSizeToFitWidth = YES;

		self.detailTextLabel.font = [UIFont fontWithName:@"Avenir" size:18.0f];
		self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];

		self.selectionStyle = UITableViewCellSelectionStyleNone;

		UIView *view = [[UIView alloc] init];
//		view.backgroundColor = [UIColor shr_blueColor];
		self.selectedBackgroundView = view;
	}
	return self;
}

@end
