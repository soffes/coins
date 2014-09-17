//
//  BTCPreferences.m
//  Coins
//
//  Created by Sam Soffes on 9/17/14.
//  Copyright (c) 2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCPreferences.h"
#import "NSUserDefaults+Coins.h"

@interface BTCPreferences ()
@property (nonatomic) NSDictionary *defaults;
@end

@implementation BTCPreferences

#pragma mark - Accessors

@synthesize defaults = _defaults;

- (void)registerDefaults:(NSDictionary *)defaults {
	self.defaults = defaults;
}


- (id)objectForKey:(NSString *)key {
	id value = [[self iCloudStore] objectForKey:key];
	if (!value) {
		value = [[self defaultsStore] objectForKey:key];
	}
	if (!value) {
		value = self.defaults[key];
	}
	return value;
}


- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
	[[self defaultsStore] setObject:object forKey:key];
	[[self iCloudStore] setObject:object forKey:key];
}


- (void)removeObjectForKey:(NSString *)key {
	[[self defaultsStore] removeObjectForKey:key];
	[[self iCloudStore] removeObjectForKey:key];
}


- (void)synchronize {
	[[self defaultsStore] synchronize];
	[[self iCloudStore] synchronize];
}


#pragma mark - Singleton

+ (instancetype)sharedPreferences {
	static BTCPreferences *preferences;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		preferences = [[self alloc] init];
	});
	return preferences;
}


#pragma mark - Private

- (NSUserDefaults *)defaultsStore {
	return [NSUserDefaults btc_sharedDefaults];
}


- (NSUbiquitousKeyValueStore *)iCloudStore {
	return [NSUbiquitousKeyValueStore defaultStore];
}

@end
