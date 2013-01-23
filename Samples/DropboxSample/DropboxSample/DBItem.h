//
//  DBItem.h
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/26/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBFolder;

@interface DBItem : NSManagedObject

@property (nonatomic, retain) NSString * rev;
@property (nonatomic, retain) NSDate * modified;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * root;
@property (nonatomic, retain) NSNumber * bytes;
@property (nonatomic, retain) DBFolder *folder;

@end
