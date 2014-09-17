//
//  BTCTickingButton.m
//  Coins
//
//  Created by Sam Soffes on 12/20/13.
//  Copyright (c) 2013-2014 Nothing Magical, Inc. All rights reserved.
//

#import "BTCTickingButton.h"
#import "NSDate+Coins.h"

@interface BTCTickingButton ()
@property (nonatomic, readwrite, getter = isTicking) BOOL ticking;
@property (nonatomic) NSTimer *timer;
@end

@implementation BTCTickingButton

#pragma mark - Accessors

@synthesize ticking = _ticking;
@synthesize date = _date;
@synthesize format = _format;
@synthesize timer = _timer;

- (void)setDate:(NSDate *)date {
	_date = date;
	[self tick];
}


- (void)setFormat:(NSString *)format {
	_format = format;
	[self tick];
}


- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.format = @"";
	}
	return self;
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
	NSString *title = self.date ? [NSString stringWithFormat:self.format, [self.date coins_timeAgoInWords]] : @"Never updated";
#pragma clang diagnostic pop
	[self setTitle:title forState:UIControlStateNormal];
}

@end
