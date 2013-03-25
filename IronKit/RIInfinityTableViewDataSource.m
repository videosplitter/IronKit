//
//  RIInfinityTableViewDataSource.m
//  TwitterTimelineSample
//
//  Created by DenGun on 25.03.13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import "RIInfinityTableViewDataSource.h"

@implementation RIInfinityTableViewDataSource

- (NSInteger)sectionsCount
{
	return self.fetchedResults.sections.count;
}

- (void)setHasMore:(BOOL)hasMore
{
	_hasMore = hasMore;
	// перезагружаем последнюю секцию
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self sectionsCount]] withRowAnimation:self.rowAnimation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self sectionsCount] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section < [self sectionsCount])
	{
		id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResults sections] objectAtIndex:section];
		return [sectionInfo numberOfObjects];
	}
	
	// для последней секции
	return _hasMore?1:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	if (indexPath.section < [self sectionsCount])
	{
		cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	}
	else
	{
		cell = self.loadMoreCell;
	}
	return cell;
}

@end
