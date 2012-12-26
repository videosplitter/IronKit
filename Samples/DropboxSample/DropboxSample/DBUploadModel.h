//
//  DBUploadModel.h
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/26/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RIModel.h"

@interface DBUploadModel : RIModel

- (void)uploadFileWithName:(NSString *)name fromPath:(NSString *)path;

@end
