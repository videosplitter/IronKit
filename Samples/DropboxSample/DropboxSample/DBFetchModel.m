//
//  RIFetchModel.m
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/25/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "DBFetchModel.h"
#import "RIModel+Private.h"

#import "DBFolder.h"
#import "DBFile.h"

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
	if (self.loading) return;
	self.loading = YES;
	
	[_restClient loadMetadata:@"/"];
}

- (void)cancelLoad {
	[_restClient cancelAllRequests];
	[super cancelLoad];
}

#pragma mark - DBRestClient delegate

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
	
	__weak DBFetchModel * weakSelf = self;
	[MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
//		DBFolder * folder = [DBFolder MR_findFirstByAttribute:@"path" withValue:@"/" inContext:localContext];
//		if (!folder) {
//			folder = [DBFolder MR_createInContext:localContext];
//			folder.dbHash = metadata.hash;
//			folder.rev = metadata.rev;
//			folder.modified = metadata.lastModifiedDate;
//			folder.path = metadata.path;
//			folder.root = metadata.root;
//		} else if (![folder.rev isEqualToString:metadata.rev]) {
//			folder.dbHash = metadata.hash;
//			folder.rev = metadata.rev;
//			folder.modified = metadata.lastModifiedDate;
//		}
		for (DBMetadata * fileMetadata in metadata.contents) {
			DBFile * file = [DBFile MR_findFirstByAttribute:@"path" withValue:fileMetadata.path inContext:localContext];
			if (!file) {
				file = [DBFile MR_createInContext:localContext];
				file.thumbnailExists = [NSNumber numberWithBool:fileMetadata.thumbnailExists];
				file.rev = fileMetadata.rev;
				file.bytes = [NSNumber numberWithLongLong:fileMetadata.totalBytes];
				file.modified = fileMetadata.lastModifiedDate;
				file.clientMtime = fileMetadata.clientMtime;
				file.path = fileMetadata.path;
				file.root = fileMetadata.root;
			} else if ([file.rev isEqualToString:fileMetadata.rev]) {
				file.thumbnailExists = [NSNumber numberWithBool:fileMetadata.thumbnailExists];
				file.rev = fileMetadata.rev;
				file.bytes = [NSNumber numberWithLongLong:fileMetadata.totalBytes];
				file.modified = fileMetadata.lastModifiedDate;
				file.clientMtime = fileMetadata.clientMtime;
				file.path = fileMetadata.path;
				file.root = fileMetadata.root;
			}
		}
		// TODO process 'contents'
	} completion:^{
		[weakSelf didFinishLoadWithResponse:nil];
	}];
	
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
	NSLog(@"");
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
	[self didFailLoadWithError:error canceled:NO];
}

@end
