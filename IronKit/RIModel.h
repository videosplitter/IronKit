//
//  RIModel.h
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/25/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const RIModelDidFinishLoadNotification;
extern NSString * const RIModelDidFailLoadNotification;

@interface RIModel : NSObject

@property (nonatomic, readonly, getter = isLoading) BOOL loading;
@property (nonatomic, readonly, getter = isLoaded) BOOL loaded;

+ (id)model;

- (void)load;
- (void)cancelLoad;

- (void)didFinishLoadWithResponse:(id)response;
- (void)didFailLoadWithError:(NSError *)error canceled:(BOOL)canceled;

@end
