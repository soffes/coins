//
//  BTCConversionProvider.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013-2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCConversionProvider.h"

#import <SAMCache/SAMCache.h>

@implementation BTCConversionProvider

static NSString *const BTCConversionProviderCacheKey = @"BTCConversion";

+ (instancetype)sharedProvider {
	static BTCConversionProvider *provider = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		provider = [[self alloc] init];
	});

	return provider;
}


- (void)getConversionRates:(void (^)(NSDictionary *, UIBackgroundFetchResult))completion {
	NSURL *URL = [[NSURL alloc] initWithString:@"https://coinbase.com/api/v1/currencies/exchange_rates"];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
	NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
		NSMutableDictionary *dictionary;
		UIBackgroundFetchResult result = UIBackgroundFetchResultFailed;

		if (response && [(NSHTTPURLResponse *)response statusCode] == 200) {
			NSData *data = [[NSData alloc] initWithContentsOfURL:location];
			NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

			NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
			for (NSString *longKey in JSON) {
				if (![longKey hasPrefix:@"btc_to_"]) {
					continue;
				}

				NSString *key = [[longKey stringByReplacingOccurrencesOfString:@"btc_to_" withString:@""] uppercaseString];
				dictionary[key] = @([JSON[longKey] doubleValue]);
			}

			SAMCache *cache = [SAMCache sharedCache];
			NSMutableDictionary *current = [[cache objectForKey:BTCConversionProviderCacheKey] mutableCopy];
			[current removeObjectForKey:@"updatedAt"];

			result = [current isEqualToDictionary:dictionary] ? UIBackgroundFetchResultNoData : UIBackgroundFetchResultNewData;

			dictionary[@"updatedAt"] = [NSDate date];
			[cache setObject:dictionary forKey:BTCConversionProviderCacheKey];
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion) {
				completion(dictionary, result);
			}
		});
	}];

	[task resume];
}


- (NSDictionary *)latestConversionRates {
	return [[SAMCache sharedCache] objectForKey:BTCConversionProviderCacheKey];
}

@end
