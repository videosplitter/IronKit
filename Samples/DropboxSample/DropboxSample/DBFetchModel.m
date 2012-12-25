//
//  RIFetchModel.m
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/25/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "DBFetchModel.h"

@interface DBFetchModel () <DBRestClientDelegate> {
	DBRestClient * _restClient;
}

@end

@implementation DBFetchModel

- (id)init {
	self = [super init];
	if (self) {
		_restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;
	}
	return self;
}

- (void)load {
	if (_loading) return;
	_loading = YES;
	
	[_restClient loadMetadata:@"/"];
}

- (void)cancelLoad {
	[_restClient cancelAllRequests];
	[super cancelLoad];
}

#pragma mark - DBRestClient delegate

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
	[self didFinishLoadWithResponse:nil];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
	NSLog(@"");
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
	[self didFailLoadWithError:error canceled:NO];
}

@end
