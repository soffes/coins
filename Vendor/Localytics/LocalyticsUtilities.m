//
//  LocalyticsUtilities.m
//  Localytics
//
//  Created by Sam Soffes on 3/27/12.
//  Copyright (c) 2012-2013 Nothing Magical. All rights reserved.
//

#import "LocalyticsUtilities.h"

void LLStartSession(NSString *key) {
#if ANALYTICS_ENABLED
	[[LocalyticsSession sharedLocalyticsSession] startSession:(key)];
#endif
}


void LLTagEvent(NSString *name) {
#if ANALYTICS_ENABLED
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:name];
#endif
}


void LLTagEventWithAttributes(NSString *name, NSDictionary *attributes) {
#if ANALYTICS_ENABLED
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:name attributes:attributes];
#endif
}


void LLTagScreen(NSString *screen) {
#if ANALYTICS_ENABLED
	[[LocalyticsSession sharedLocalyticsSession] tagScreen:screen];
#endif
}
