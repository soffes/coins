//
//  NSUserDefaults+Coins.m
//  Coins
//
//  Created by Sam Soffes on 9/17/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

#import "NSUserDefaults+Coins.h"

@implementation NSUserDefaults (Coins)

+ (instancetype)btc_sharedDefaults {
	static NSUserDefaults *defaults;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaults = [[self alloc] initWithSuiteName:@"group.com.nothingmagical.coins"];
	});
	return defaults;
}

@end
