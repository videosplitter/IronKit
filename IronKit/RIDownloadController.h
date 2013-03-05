//
//  RIModel.h
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/25/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RIDownloadController;

@protocol RIDownloadControllerDelegate <NSObject>

@optional
- (void)controller:(RIDownloadController *)controller didFinishLoadWithResponse:(id)response;
- (void)controller:(RIDownloadController *)controller didFailLoadWithError:(NSError *)error;
- (void)controllerDidCancelLoad:(RIDownloadController *)controller;

@end

@interface RIDownloadController : NSObject

@property (nonatomic, weak) id<RIDownloadControllerDelegate> delegate;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, readonly, getter = isLoading) BOOL loading;
@property (nonatomic, readonly, getter = isLoaded) BOOL loaded;

- (BOOL)reload;
- (BOOL)loadMore;
- (BOOL)cancelLoad;

- (void)didFinishLoadWithResponse:(id)response;
- (void)didFailLoadWithError:(NSError *)error;

@end
