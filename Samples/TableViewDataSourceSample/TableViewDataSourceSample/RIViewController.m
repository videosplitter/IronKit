//
//  RIViewController.m
//  TableViewDataSourceSample
//
//  Created by Ali Gadzhiev on 12/19/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RIViewController.h"
#import "RITableViewDataSource.h"

#import "RIRefreshControl.h"

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
    
    NSMutableArray * images = [NSMutableArray array];
    for (unsigned i = 1; i < 20; ++i)
    {
        NSString * index = [NSString stringWithFormat:i < 10 ? @"0%d" : @"%d", i];
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"spinner00%@.png", index]]];
    }
    UIImageView * activityView = [[UIImageView alloc] init];
    activityView.animationImages = images;
    activityView.animationDuration = 1.0;
    [activityView sizeToFit];
	
	RIRefreshControl * refreshControl = [[RIRefreshControl alloc] init];
//    refreshControl.activityIndicator = activityView;
    refreshControl.arrowImage = [UIImage imageNamed:@"refresh.png"];
	[refreshControl addTarget:self action:@selector(refreshControlDidChangeState:) forControlEvents:UIControlEventValueChanged];
	self.tableView.refreshControl = refreshControl;
}

- (void)refreshControlDidChangeState:(RIRefreshControl *)sender {
	if (sender.refreshing) {
		[sender performSelector:@selector(endRefreshing) withObject:nil afterDelay:3.0];
	} else {
		[NSObject cancelPreviousPerformRequestsWithTarget:sender selector:@selector(endRefreshing) object:nil];
	}
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
