//
//  RIModel.m
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/25/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RIDownloadController.h"

@interface RIDownloadController ()

@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@property (nonatomic, readwrite, getter = isLoaded) BOOL loaded;

@end

@implementation RIDownloadController

- (BOOL)reload
{
	return NO;
}

- (BOOL)loadMore
{
    return NO;
}

- (BOOL)cancelLoad
{
	if (!self.loading) return NO;
    
    if ([self.delegate respondsToSelector:@selector(controllerDidCancelLoad:)])
    {
        [self.delegate controllerDidCancelLoad:self];
    }
    return YES;
}

#pragma mark - Loading end points

- (void)didFinishLoadWithResponse:(id)response {
    __weak RIDownloadController * weakSelf = self;
	void (^block)(void) = ^{
		weakSelf.loading = NO;
		weakSelf.loaded = YES;
		
        if ([weakSelf.delegate respondsToSelector:@selector(controller:didFinishLoadWithResponse:)])
        {
            [weakSelf.delegate controller:weakSelf didFinishLoadWithResponse:response];
        }
	};
	
	if ([NSThread isMainThread])
    {
		block();
	}
    else
    {
		dispatch_async(dispatch_get_main_queue(), block);
	}
}

- (void)didFailLoadWithError:(NSError *)error {
    __weak RIDownloadController * weakSelf = self;
	void (^block)(void) = ^{
		weakSelf.loading = NO;
		weakSelf.loaded |= NO;
		
		if ([weakSelf.delegate respondsToSelector:@selector(controller:didFailLoadWithError:)])
        {
            [weakSelf.delegate controller:weakSelf didFailLoadWithError:error];
        }
	};
	
	if ([NSThread isMainThread])
    {
		block();
	}
    else
    {
		dispatch_async(dispatch_get_main_queue(), block);
	}
}

@end
