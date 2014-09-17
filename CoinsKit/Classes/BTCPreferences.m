//
//  BTCPreferences.m
//  Coins
//
//  Created by Sam Soffes on 9/17/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCPreferences.h"
#import "NSUserDefaults+Coins.h"

@implementation BTCPreferences

+ (instancetype)sharedPreferences {
	static BTCPreferences *preferences;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		preferences = [[self alloc] init];
	});
	return preferences;
}


- (void)registerDefaults:(NSDictionary *)defaults {
	[[NSUserDefaults btc_sharedDefaults] registerDefaults:defaults];
}


- (id)objectForKey:(NSString *)key {
	return [[NSUserDefaults btc_sharedDefaults] objectForKey:key];
}


- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
	[[NSUserDefaults btc_sharedDefaults] setObject:object forKey:key];
}


- (void)removeObjectForKey:(NSString *)key {
	[[NSUserDefaults btc_sharedDefaults] removeObjectForKey:key];
}


- (void)synchronize {
	[[NSUserDefaults btc_sharedDefaults] synchronize];
}

@end
