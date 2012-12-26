//
//  DBFolder.h
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/26/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DBItem.h"


@interface DBFolder : DBItem

@property (nonatomic, retain) NSString * dbHash;
@property (nonatomic, retain) NSSet *items;
@end

@interface DBFolder (CoreDataGeneratedAccessors)

- (void)addItemsObject:(NSManagedObject *)value;
- (void)removeItemsObject:(NSManagedObject *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
