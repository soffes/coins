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
	id value = [[self defaultsStore] objectForKey:key];
	if (value) {
		return value;
	}
	return self.defaults[key];
}


- (double)doubleForKey:(NSString *)key {
	return [[self objectForKey:key] doubleValue];
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
	[[self iCloudStore] synchronize];
	[[self defaultsStore] synchronize];
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


#pragma mark - NSObject

- (instancetype)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudStoreDidChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
	}
	return self;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private

- (NSUserDefaults *)defaultsStore {
	return [NSUserDefaults btc_sharedDefaults];
}


- (NSUbiquitousKeyValueStore *)iCloudStore {
	return [NSUbiquitousKeyValueStore defaultStore];
}


- (void)iCloudStoreDidChange:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *changeReason = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
	NSInteger reason = -1;

	if (!changeReason) {
		return;
	} else {
		reason = [changeReason integerValue];
	}

	if (reason == NSUbiquitousKeyValueStoreServerChange || reason == NSUbiquitousKeyValueStoreInitialSyncChange) {
		NSArray *changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
		NSUbiquitousKeyValueStore *store = [self iCloudStore];

		for (NSString *key in changedKeys) {
			[[self defaultsStore] setObject:[store objectForKey:key] forKey:key];
		}
	}
}

@end
