//
//  BTCConversionProvider.h
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013-2014 Nothing Magical, Inc. All rights reserved.
//

@import UIKit;

@interface BTCConversionProvider : NSObject

+ (instancetype)sharedProvider;

- (void)getConversionRates:(void(^)(NSDictionary *conversionRates, UIBackgroundFetchResult result))completion;
- (NSDictionary *)latestConversionRates;

@end
