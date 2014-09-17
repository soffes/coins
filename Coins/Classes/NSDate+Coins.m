//
//  NSDate+Coins.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013-2014 Nothing Magical, Inc. All rights reserved.
//

#import "NSDate+Coins.h"

@implementation NSDate (Coins)

- (NSString *)coins_timeAgoInWords {
	NSTimeInterval intervalInSeconds = fabs([self timeIntervalSinceNow]);
	BOOL includeSeconds = YES;
	NSTimeInterval intervalInMinutes = round(intervalInSeconds / 60.0f);

	if (intervalInMinutes >= 0 && intervalInMinutes <= 1) {
		if (!includeSeconds) {
			return intervalInMinutes <= 0 ? @"less than a minute ago" : @"1 minute ago";
		}
		if (intervalInSeconds >= 0 && intervalInSeconds < 10) {
			return @"just now";
		} else if (intervalInSeconds >= 10 && intervalInSeconds < 60) {
			return [NSString stringWithFormat:@"%ld seconds ago", (long)intervalInSeconds];
		} else {
			return @"1 minute ago";
		}
	} else if (intervalInMinutes >= 2 && intervalInMinutes <= 44) {
		return [NSString stringWithFormat:@"%ld minutes ago", (long)intervalInMinutes];
	} else if (intervalInMinutes >= 45 && intervalInMinutes <= 89) {
		return @"about 1 hour ago";
	} else if (intervalInMinutes >= 90 && intervalInMinutes <= 1439) {
		return [NSString stringWithFormat:@"%ld hours ago", (long)ceilf((CGFloat)intervalInMinutes / 60.0f)];
	} else if (intervalInMinutes >= 1440 && intervalInMinutes <= 2879) {
		return @"1 day ago";
	} else if (intervalInMinutes >= 2880 && intervalInMinutes <= 43199) {
		return [NSString stringWithFormat:@"%ld days ago", (long)ceilf((CGFloat)intervalInMinutes / 1440.0f)];
	} else if (intervalInMinutes >= 43200 && intervalInMinutes <= 86399) {
		return @"1 month ago";
	} else if (intervalInMinutes >= 86400 && intervalInMinutes <= 525599) {
		return [NSString stringWithFormat:@"%ld months ago", (long)ceilf((CGFloat)intervalInMinutes / 43200.0f)];
	} else if (intervalInMinutes >= 525600 && intervalInMinutes <= 1051199) {
		return @"1 year ago";
	} else {
		return [NSString stringWithFormat:@"%ld years ago", (long)ceilf((CGFloat)intervalInMinutes / 525600.0f)];
	}
	return nil;
}

@end
