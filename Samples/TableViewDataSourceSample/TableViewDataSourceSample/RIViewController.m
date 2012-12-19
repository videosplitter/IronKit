//
//  RIViewController.m
//  TableViewDataSourceSample
//
//  Created by Ali Gadzhiev on 12/19/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RIViewController.h"
#import "RITableViewDataSource.h"

#import "Entity.h"

@interface RIViewController () {
	RITableViewDataSource	* _dataSource;
}

@end

@implementation RIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	_dataSource = [[RITableViewDataSource alloc] init];
	_dataSource.fetchedResults = [Entity MR_fetchAllGroupedBy:nil withPredicate:nil sortedBy:@"name" ascending:YES];
	[_dataSource registerClass:[UITableViewCell class] forCellWithReuseIdentifier:@"Cell"];
	[_dataSource setReusableIdentifierBlock:^NSString *(NSIndexPath * indexPath) {
		return @"Cell";
	}];
	[_dataSource setConfigureCellBlock:^(UITableViewCell * cell, NSIndexPath * indexPath, id object) {
		cell.textLabel.text = [(Entity *)object name];
	}];
	_dataSource.tableView = self.tableView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	_dataSource = nil;
	[super viewDidUnload];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
