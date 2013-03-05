//
//  TWTweet.h
//  TwitterTimelineSample
//
//  Created by Ali Gadzhiev on 1/24/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TWTweet : NSManagedObject

@property (nonatomic, retain) NSNumber * tweetId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * retweeted;
@property (nonatomic, retain) NSNumber * retweetCount;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSManagedObject *user;

@end
