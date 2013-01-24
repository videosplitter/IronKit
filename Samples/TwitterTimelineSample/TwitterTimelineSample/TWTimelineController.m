//
//  TWTimelineController.m
//  TwitterTimelineSample
//
//  Created by Ali Gadzhiev on 1/24/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "TWTimelineController.h"

#import "TWTweet.h"

@interface TWTimelineController ()

@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@property (nonatomic, strong) ACAccountStore * accountStore;
@property (nonatomic, strong) ACAccount * twitterAccount;

@end

@implementation TWTimelineController

- (ACAccountStore *)accountStore
{
    if (!_accountStore)
    {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

- (BOOL)reload
{
    if (self.loading) return NO;
    self.loading = YES;
    
    NSURL * URL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    TWRequest * request = [[TWRequest alloc] initWithURL:URL parameters:nil requestMethod:TWRequestMethodGET];
    
    // We only want to receive Twitter accounts
    ACAccountType * twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Obtain the user's permission to access the store
    [self.accountStore requestAccessToAccountsWithType:twitterType withCompletionHandler:^(BOOL granted, NSError *error) {
        if (!granted)
        {
            // handle this scenario gracefully
            return;
        }
        
        // obtain all the local account instances
        NSArray * accounts = [self.accountStore accountsWithAccountType:twitterType];
        
        // for simplicity, we will choose the first account returned - in your app,
        // you should ensure that the user chooses the correct Twitter account
        // to use with your application.  DO NOT FORGET THIS STEP.
        [request setAccount:[accounts objectAtIndex:0]];
        
        // execute the request
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            __block NSArray * tweetsObjects = nil;
            if (!error)
            {
                tweetsObjects = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
            }
            if (error)
            {
                [self didFailLoadWithError:error];
                return;
            }
            
            NSLog(@"%@", tweetsObjects);
            [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
                tweetsObjects = [tweetsObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [[obj1 valueForKey:@"id"] compare:[obj2 valueForKey:@"id"]];
                }];
                NSArray * tweetsIds = [tweetsObjects valueForKey:@"id"];
                
                [TWTweet MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"NOT tweetId IN %@", tweetsIds] inContext:localContext];
                NSArray * tweets = [TWTweet MR_findAllSortedBy:@"tweetId" ascending:YES
                                                 withPredicate:[NSPredicate predicateWithFormat:@"tweetId IN %@", tweetsIds] inContext:localContext];
                NSEnumerator * tweetsEnumerator = [tweets objectEnumerator];
                TWTweet * currentTweet = [tweetsEnumerator nextObject];
                for (NSDictionary * tweetObject in tweetsObjects)
                {
                    TWTweet * tweet = nil;
                    if ([[tweetObject valueForKey:@"id"] isEqual:currentTweet.tweetId])
                    {
                        tweet = currentTweet;
                        currentTweet = [tweetsEnumerator nextObject];
                    }
                    else
                    {
                        tweet = [TWTweet MR_createInContext:localContext];
                    }
                    
                    [tweet MR_importValuesForKeysWithObject:tweetObject];
                }
            } completion:^{
                [self didFinishLoadWithResponse:tweetsObjects];
            }];
        }];
    }];

    return YES;
}

@end
