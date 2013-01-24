//
//  TWUser.h
//  TwitterTimelineSample
//
//  Created by Ali Gadzhiev on 1/24/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TWTweet;

@interface TWUser : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSSet *tweets;
@end

@interface TWUser (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(TWTweet *)value;
- (void)removeTweetsObject:(TWTweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
