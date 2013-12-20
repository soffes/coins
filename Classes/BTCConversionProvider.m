//
//  BTCConversionProvider.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013 Nothing Magical, Inc. All rights reserved.
//

#import "BTCConversionProvider.h"

#import <SAMCache/SAMCache.h>

@implementation BTCConversionProvider

+ (instancetype)sharedProvider {
	static BTCConversionProvider *provider = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		provider = [[self alloc] init];
	});

	return provider;
}


- (void)getConversionRates:(void (^)(NSDictionary *))completion {
	if (completion) {
		[[SAMCache sharedCache] objectForKey:@"BTCConversion" usingBlock:^(id<NSCopying> object) {
			if (object) {
				completion((NSDictionary *)object);
			}
		}];
	}

	NSURL *URL = [[NSURL alloc] initWithString:@"https://coinbase.com/api/v1/currencies/exchange_rates"];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
	NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
		NSData *data = [[NSData alloc] initWithContentsOfURL:location];
		NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
		for (NSString *longKey in JSON) {
			if (![longKey hasPrefix:@"btc_to_"]) {
				continue;
			}

			NSString *key = [[longKey stringByReplacingOccurrencesOfString:@"btc_to_" withString:@""] uppercaseString];
			dictionary[key] = @([JSON[longKey] floatValue]);
		}

		dictionary[@"updatedAt"] = [NSDate date];

		[[SAMCache sharedCache] setObject:dictionary forKey:@"BTCConversion"];

		if (completion) {
			completion(dictionary);
		}
	}];

	[task resume];
}

@end
