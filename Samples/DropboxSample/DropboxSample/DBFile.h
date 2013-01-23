//
//  DBFile.h
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/26/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DBItem.h"


@interface DBFile : DBItem

@property (nonatomic, retain) NSNumber * thumbnailExists;
@property (nonatomic, retain) NSDate * clientMtime;

@end
