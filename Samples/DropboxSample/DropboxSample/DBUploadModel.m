//
//  DBUploadModel.m
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/26/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "DBUploadModel.h"
#import "RIModel+Private.h"

#import "DBFile.h"

@interface DBUploadModel () <DBRestClientDelegate> {
	DBRestClient * _restClient;
}

@end

@implementation DBUploadModel

- (id)init {
	self = [super init];
	if (self) {
		_restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;
	}
	return self;
}

- (void)uploadFileWithName:(NSString *)name fromPath:(NSString *)path {
	if (self.loading) return;
	self.loading = YES;
	
	[_restClient uploadFile:name toPath:@"/" withParentRev:nil fromPath:path];
}

#pragma mark - DB Rest client delegate

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath {
//	NSLog(@"%@", destPath);
//	NSLog(@"%@", srcPath);
	[_restClient loadMetadata:destPath];
	[self didFinishLoadWithResponse:nil];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
	NSLog(@"%@", error);
	[self didFailLoadWithError:error canceled:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/*
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
	
	__weak DBUploadModel * weakSelf = self;
	[MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
		DBFile * file = [DBFile MR_createInContext:localContext];
		file.thumbnailExists = [NSNumber numberWithBool:metadata.thumbnailExists];
		file.rev = metadata.rev;
		file.bytes = [NSNumber numberWithLongLong:metadata.totalBytes];
		file.modified = metadata.lastModifiedDate;
		file.clientMtime = metadata.clientMtime;
		file.path = metadata.path;
		file.root = metadata.root;
		NSLog(@"%@", file);
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
*/
@end
