//
//  RITableViewDataSource.h
//  TableViewDataSourceSample
//
//  Created by Ali Gadzhiev on 12/19/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RITableViewDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic) UITableViewRowAnimation rowAnimation;
@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, strong) NSFetchedResultsController * fetchedResults;
@property (nonatomic, copy) void(^configureCellBlock)(UITableViewCell * cell, NSIndexPath * indexPath, id object);
@property (nonatomic, copy) NSString * (^reusableIdentifierBlock)(NSIndexPath * indexPath);

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResults;

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;
- (UITableViewCell *)cellForObject:(id)object;

@end
