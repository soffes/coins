//
//  BTCTickingButton.h
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013-2014 Nothing Magical, Inc. All rights reserved.
//

@interface BTCTickingButton : UIButton

@property (nonatomic, readonly, getter = isTicking) BOOL ticking;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSString *format;

- (void)startTicking;
- (void)stopTicking;

@end
