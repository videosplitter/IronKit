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
@property (nonatomic, readwrite) BOOL hasMore;
@property (nonatomic, strong) ACAccountStore * accountStore;
@property (nonatomic, strong) ACAccount * twitterAccount;
@property (nonatomic, strong) NSNumber * lastID;
@end

@implementation TWTimelineController
@synthesize hasMore = _hasMore;

- (ACAccountStore *)accountStore
{
    if (!_accountStore)
    {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

- (BOOL)loadMore
{
	if (self.loading) return NO;
    self.loading = YES;
	
	if (!self.lastID) {
		return NO;
	}
	
	NSURL * URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/home_timeline.json?max_id=%@", self.lastID]];
	[self loadURL:URL];
	
	return YES;
}

- (BOOL)reload
{
    if (self.loading) return NO;
    self.loading = YES;
    
    NSURL * URL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
	[self loadURL:URL];
	
    return YES;
}

- (void)loadURL:(NSURL *)url
{
	TWRequest * request = [[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodGET];
    
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
            
			if ([urlResponse statusCode] == 429) {
				dispatch_async(dispatch_get_main_queue(), ^{
					NSString *message = [[[tweetsObjects valueForKey:@"errors"] objectAtIndex:0] valueForKey:@"message"];
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
					[alert show];
				});
				[self didFailLoadWithError:nil];
				return;
			}
            NSLog(@"%@", tweetsObjects);
            [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
				if (![tweetsObjects isKindOfClass:[NSArray class]]) {
					return;
				}
                tweetsObjects = [tweetsObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [[obj1 valueForKey:@"id"] compare:[obj2 valueForKey:@"id"]];
                }];
                NSArray * tweetsIds = [tweetsObjects valueForKey:@"id"];
                
//                [TWTweet MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"NOT tweetId IN %@", tweetsIds] inContext:localContext];
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
				TWTweet * lastTweet = [TWTweet MR_findFirstWithPredicate:nil sortedBy:@"tweetId" ascending:YES];
				self.lastID = lastTweet.tweetId;
				self.hasMore = ([tweetsObjects count] > 0);
                [self didFinishLoadWithResponse:tweetsObjects];
            }];
        }];
    }];

}

@end
