//
//  BTCConversionProvider.h
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013 Nothing Magical, Inc. All rights reserved.
//

@interface BTCConversionProvider : NSObject

+ (instancetype)sharedProvider;

- (void)getConversionRates:(void(^)(NSDictionary *conversionRates))completion;

@end
