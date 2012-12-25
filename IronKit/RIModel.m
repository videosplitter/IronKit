//
//  RIModel.m
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/25/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RIModel.h"

NSString * const NIModelDidFinishLoadNotification	= @"com.ironkit.ModelDidFinishLoad";
NSString * const NIModelDidFailLoadNotification		= @"com.ironkit.ModelDidFailLoad";

@implementation RIModel

+ (id)model {
	return [[self alloc] init];
}

- (void)load {
	
}

- (void)cancelLoad {
	[self didFailLoadWithError:nil canceled:YES];
}

#pragma mark - Loading end points

- (void)didFinishLoadWithResponse:(id)response {
	void (^block)(void) = ^{
		_loading = NO;
		_loaded = YES;
		
		NSDictionary * userInfo = nil;
		if (response) {
			userInfo = @{ @"response" : response };
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:NIModelDidFinishLoadNotification
															object:self
														  userInfo:userInfo];
	};
	
	if ([NSThread isMainThread]) {
		block();
	} else {
		dispatch_async(dispatch_get_main_queue(), block);
	}
}

- (void)didFailLoadWithError:(NSError *)error canceled:(BOOL)canceled {
	void (^block)(void) = ^{
		_loading = NO;
		_loaded |= NO;
		
		NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:canceled]
																			forKey:@"canceled"];
		if (error) {
			[userInfo setObject:error forKey:@"error"];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:NIModelDidFailLoadNotification
															object:self
														  userInfo:userInfo];
	};
	
	if ([NSThread isMainThread]) {
		block();
	} else {
		dispatch_async(dispatch_get_main_queue(), block);
	}
}

@end
