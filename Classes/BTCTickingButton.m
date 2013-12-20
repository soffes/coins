//
//  BTCTickingButton.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013 Nothing Magical, Inc. All rights reserved.
//

#import "BTCTickingButton.h"
#import "NSDate+Coins.h"

@interface BTCTickingButton ()
@property (nonatomic, readwrite, getter = isTicking) BOOL ticking;
@property (nonatomic) NSTimer *timer;
@end

@implementation BTCTickingButton

- (void)setDate:(NSDate *)date {
	_date = date;
	[self tick];
}


- (void)setFormat:(NSString *)format {
	_format = format;
	[self tick];
}


- (void)startTicking {
	if (self.ticking) {
		return;
	}
	self.ticking = YES;

	self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}


- (void)stopTicking {
	if (!self.ticking) {
		return;
	}

	self.ticking = NO;

	[self.timer invalidate];
}


- (void)tick {
	NSString *title = [NSString stringWithFormat:self.format, [self.date coins_timeAgoInWords]];
	[self setTitle:title forState:UIControlStateNormal];
}

@end
