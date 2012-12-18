//
//  RITableViewDataSource.m
//  TableViewDataSourceSample
//
//  Created by Ali Gadzhiev on 12/19/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RITableViewDataSource.h"

@interface RITableViewDataSource () {
	NSMutableDictionary	* _cellClasses;
}

@end

@implementation RITableViewDataSource

- (id)init {
	self = [super init];
	if (self) {
		_cellClasses = [NSMutableDictionary dictionary];
		_rowAnimation = UITableViewRowAnimationNone;
	}
	return self;
}

- (void)setFetchedResults:(NSFetchedResultsController *)fetchedResults {
	if (fetchedResults == _fetchedResults) return;
	_fetchedResults.delegate = nil;
	_fetchedResults = fetchedResults;
	_fetchedResults.delegate = self;
	[_tableView reloadData];
}

- (void)setTableView:(UITableView *)tableView {
	if (tableView == _tableView) return;
	_tableView.dataSource = nil;
	_tableView = tableView;
	_tableView.dataSource = self;
	[_tableView reloadData];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
	[_cellClasses setObject:cellClass forKey:identifier];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	return [_fetchedResults objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForObject:(id)object {
	return [_fetchedResults indexPathForObject:object];
}

- (UITableViewCell *)cellForObject:(id)object {
	return [_tableView cellForRowAtIndexPath:[self indexPathForObject:object]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[_fetchedResults sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id<NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResults sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString * identifier = nil;
	if (_reusableIdentifierBlock) {
		identifier = _reusableIdentifierBlock(indexPath);
	}
	
	Class cellClass = [_cellClasses objectForKey:identifier];
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		cell = [(UITableViewCell *)[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	
	if (_configureCellBlock) {
		_configureCellBlock(cell, indexPath, [_fetchedResults objectAtIndexPath:indexPath]);
	}
	return cell;
}

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[_tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch (type) {
		case NSFetchedResultsChangeInsert: {
			[_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:_rowAnimation];
			break;
		}
			
		case NSFetchedResultsChangeDelete: {
			[_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:_rowAnimation];
			break;
		}
		case NSFetchedResultsChangeMove: {
			[_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:_rowAnimation];
			[_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:_rowAnimation];
			break;
		}
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	switch (type) {
		case NSFetchedResultsChangeInsert: {
			[_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:_rowAnimation];
			break;
		}
		case NSFetchedResultsChangeDelete: {
			[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:_rowAnimation];
			break;
		}
		case NSFetchedResultsChangeMove: {
			[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:_rowAnimation];
			[_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:_rowAnimation];
			break;
		}
		case NSFetchedResultsChangeUpdate: {
			[_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:_rowAnimation];
			break;
		}
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[_tableView endUpdates];
}

@end
