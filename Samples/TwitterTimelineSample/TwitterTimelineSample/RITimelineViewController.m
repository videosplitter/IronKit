//
//  RITimelineViewController.m
//  TwitterTimelineSample
//
//  Created by Ali Gadzhiev on 1/24/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import "RITimelineViewController.h"
#import "TWTimelineController.h"
#import "RIRefreshControl.h"
#import "RITableViewDataSource.h"
#import "TWTweet.h"

@interface RITimelineViewController () <UITableViewDelegate, RIDownloadControllerDelegate>

@property (nonatomic, strong) RIRefreshControl * refreshControl;

@property (nonatomic, strong) RITableViewDataSource * dataSource;
@property (nonatomic, strong) TWTimelineController * downloadController;

@end

@implementation RITimelineViewController

- (void)loadView
{
    UITableView * tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    self.view = tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.refreshControl = self.refreshControl;
    self.dataSource.tableView = self.tableView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    self.refreshControl = nil;
    [super viewDidUnload];
}

- (RITableViewDataSource *)dataSource
{
    if (!_dataSource)
    {
        NSFetchedResultsController * fetchedResults = [TWTweet MR_fetchAllGroupedBy:nil withPredicate:nil sortedBy:@"createDate" ascending:YES];
        RITableViewDataSource * dataSource = [[RITableViewDataSource alloc] initWithFetchedResultsController:fetchedResults];
        [dataSource registerClass:[UITableViewCell class] forCellWithReuseIdentifier:@"Cell"];
        [dataSource setReusableIdentifierBlock:^NSString *(NSIndexPath * indexPath) {
            return @"Cell";
        }];
        [dataSource setConfigureCellBlock:^(UITableViewCell * cell, NSIndexPath * indexPath, TWTweet * tweet) {
            cell.textLabel.text = tweet.text;
        }];
        _dataSource = dataSource;
    }
    return _dataSource;
}

- (TWTimelineController *)downloadController
{
    if (!_downloadController)
    {
        _downloadController = [[TWTimelineController alloc] init];
        _downloadController.delegate = self;
    }
    return _downloadController;
}

- (RIRefreshControl *)refreshControl
{
    if (!_refreshControl)
    {
        RIRefreshControl * refreshControl = [[RIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(refreshControlDidChangeState:) forControlEvents:UIControlEventValueChanged];
        _refreshControl = refreshControl;
    }
    return _refreshControl;
    
}

- (void)refreshControlDidChangeState:(RIRefreshControl *)refreshControl
{
    if (self.refreshControl.refreshing)
    {
        [self.downloadController cancelLoad];
        [self.downloadController reload];
    }
}

- (void)setTableView:(UITableView *)tableView
{
    [(UITableView *)self.view setDelegate:nil];
    self.view = tableView;
    [(UITableView *)self.view setDelegate:self];
}

- (UITableView *)tableView
{
    return (UITableView *)self.view;
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

#pragma mark - Download controller delegate

- (void)controller:(RIDownloadController *)controller didFinishLoadWithResponse:(id)response
{
    [self.refreshControl endRefreshing];
}

- (void)controller:(RIDownloadController *)controller didFailLoadWithError:(NSError *)error
{
    [self.refreshControl endRefreshing];
}

@end
