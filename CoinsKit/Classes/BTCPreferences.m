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
	NSDictionary *iCloud = [[self iCloudStore] dictionaryRepresentation];
	for (NSString *key in iCloud) {
		[[self defaultsStore] setObject:iCloud[key] forKey:key];
	}
}

@end
