//
//  BTCTableViewCell.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013-2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCTableViewCell.h"

@implementation BTCTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])) {
		self.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:18.0f];
		self.textLabel.textColor = [UIColor colorWithWhite:0.4f alpha:1.0f];
		self.textLabel.highlightedTextColor = [UIColor whiteColor];
		self.textLabel.adjustsFontSizeToFitWidth = YES;

		self.detailTextLabel.font = [UIFont fontWithName:@"Avenir" size:18.0f];
		self.detailTextLabel.textColor = [self.textLabel.textColor colorWithAlphaComponent:0.5f];
		self.detailTextLabel.highlightedTextColor = self.textLabel.highlightedTextColor;

		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			UIView *background = [[UIView alloc] init];
			background.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
			self.backgroundView = background;
		}

		UIView *selected = [[UIView alloc] init];
		selected.backgroundColor = [UIColor colorWithRed:0.102f green:0.451f blue:0.635f alpha:1.0f];
		self.selectedBackgroundView = selected;
	}
	return self;
}


- (void)layoutSubviews {
	[super layoutSubviews];

	CGRect rect = self.textLabel.frame;
	rect.size.width = fminf(rect.size.width, 240.0f);
	self.textLabel.frame = rect;

	CGSize size = self.contentView.bounds.size;
	self.detailTextLabel.frame = CGRectMake(size.width - 70.0f, 10.0f, 60.0f, size.height - 20.0f);
}

@end
