//
//  RITableViewDataSource.m
//  TableViewDataSourceSample
//
//  Created by Ali Gadzhiev on 12/19/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RITableViewDataSource.h"

@interface RITableViewDataSource ()

@property (nonatomic, strong) NSMutableDictionary * cellClasses;

@end

@implementation RITableViewDataSource

- (id)init
{
	self = [self initWithFetchedResultsController:nil];
	return self;
}

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResults
{
    self = [super init];
    if (self)
    {
        self.fetchedResults = fetchedResults;
        self.cellClasses = [NSMutableDictionary dictionary];
		self.rowAnimation = UITableViewRowAnimationNone;
    }
    return self;
}

- (void)setFetchedResults:(NSFetchedResultsController *)fetchedResults
{
	if (fetchedResults == _fetchedResults) return;
    
	_fetchedResults.delegate = nil;
	_fetchedResults = fetchedResults;
	_fetchedResults.delegate = self;
	[self.tableView reloadData];
}

- (void)setTableView:(UITableView *)tableView
{
	if (tableView == _tableView) return;
    
	_tableView.dataSource = nil;
	_tableView = tableView;
	_tableView.dataSource = self;
	[_tableView reloadData];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
	[self.cellClasses setObject:cellClass forKey:identifier];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
	return [self.fetchedResults objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForObject:(id)object
{
	return [self.fetchedResults indexPathForObject:object];
}

- (UITableViewCell *)cellForObject:(id)object
{
	return [self.tableView cellForRowAtIndexPath:[self indexPathForObject:object]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResults sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResults sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString * identifier = nil;
	if (self.reusableIdentifierBlock)
    {
		identifier = self.reusableIdentifierBlock(indexPath);
	}
	
	Class cellClass = [self.cellClasses objectForKey:identifier];
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		cell = [(UITableViewCell *)[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	
	if (self.configureCellBlock)
    {
		self.configureCellBlock(cell, indexPath, [self.fetchedResults objectAtIndexPath:indexPath]);
	}
	return cell;
}

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	switch (type)
    {
		case NSFetchedResultsChangeInsert:
        {
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:self.rowAnimation];
			break;
		}
			
		case NSFetchedResultsChangeDelete:
        {
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:self.rowAnimation];
			break;
		}
		case NSFetchedResultsChangeMove:
        {
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:self.rowAnimation];
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:self.rowAnimation];
			break;
		}
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	switch (type) {
		case NSFetchedResultsChangeInsert:
        {
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:self.rowAnimation];
			break;
		}
		case NSFetchedResultsChangeDelete:
        {
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:self.rowAnimation];
			break;
		}
		case NSFetchedResultsChangeMove:
        {
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:self.rowAnimation];
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:self.rowAnimation];
			break;
		}
		case NSFetchedResultsChangeUpdate:
        {
            BOOL selectRow = [[self.tableView indexPathsForSelectedRows] containsObject:indexPath];
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:self.rowAnimation];
            if (selectRow)
            {
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            
			break;
		}
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView endUpdates];
}

@end
