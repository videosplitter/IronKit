//
//  RIModel.m
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/25/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RIModel.h"

NSString * const RIModelDidFinishLoadNotification	= @"com.ironkit.ModelDidFinishLoad";
NSString * const RIModelDidFailLoadNotification		= @"com.ironkit.ModelDidFailLoad";

@interface RIModel ()

@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@property (nonatomic, readwrite, getter = isLoaded) BOOL loaded;

@end

@implementation RIModel

+ (id)model {
	return [[self alloc] init];
}

- (void)load {
	
}

- (void)cancelLoad
{
	if (self.loading)
    {
        [self didFailLoadWithError:nil canceled:YES];
    }
}

#pragma mark - Loading end points

- (void)didFinishLoadWithResponse:(id)response {
    __weak RIModel * weakSelf = self;
	void (^block)(void) = ^{
		weakSelf.loading = NO;
		weakSelf.loaded = YES;
		
		NSDictionary * userInfo = nil;
		if (response) {
			userInfo = @{ @"response" : response };
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:RIModelDidFinishLoadNotification
															object:weakSelf
														  userInfo:userInfo];
	};
	
	if ([NSThread isMainThread]) {
		block();
	} else {
		dispatch_async(dispatch_get_main_queue(), block);
	}
}

- (void)didFailLoadWithError:(NSError *)error canceled:(BOOL)canceled {
    __weak RIModel * weakSelf = self;
	void (^block)(void) = ^{
		weakSelf.loading = NO;
		weakSelf.loaded |= NO;
		
		NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:canceled]
																			forKey:@"canceled"];
		if (error) {
			[userInfo setObject:error forKey:@"error"];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:RIModelDidFailLoadNotification
															object:weakSelf
														  userInfo:userInfo];
	};
	
	if ([NSThread isMainThread]) {
		block();
	} else {
		dispatch_async(dispatch_get_main_queue(), block);
	}
}

@end
