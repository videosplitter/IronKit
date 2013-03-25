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
#import "RIInfinityTableViewDataSource.h"
#import "TWTweet.h"

@interface RITimelineViewController () <UITableViewDelegate, RIDownloadControllerDelegate>

@property (nonatomic, strong) RIRefreshControl * refreshControl;

@property (nonatomic, strong) RIInfinityTableViewDataSource * dataSource;
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
	[self.downloadController reload];
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

- (RIInfinityTableViewDataSource *)dataSource
{
    if (!_dataSource)
    {
        NSFetchedResultsController * fetchedResults = [TWTweet MR_fetchAllGroupedBy:nil withPredicate:nil sortedBy:@"createDate" ascending:NO];
        RIInfinityTableViewDataSource * dataSource = [[RIInfinityTableViewDataSource alloc] initWithFetchedResultsController:fetchedResults];
        [dataSource registerClass:[UITableViewCell class] forCellWithReuseIdentifier:@"Cell"];
        [dataSource setReusableIdentifierBlock:^NSString *(NSIndexPath * indexPath) {
            return @"Cell";
        }];
        [dataSource setConfigureCellBlock:^(UITableViewCell * cell, NSIndexPath * indexPath, TWTweet * tweet) {
			
			NSDateFormatter *dateFormatter = [NSDateFormatter new]; //вынести в static
			[dateFormatter setDateFormat:@"HH:mm DD MMM YYYY"];
			
			[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
            cell.textLabel.text = tweet.text;
			
			cell.detailTextLabel.text = [dateFormatter stringFromDate:tweet.createDate];
        }];
		
		[dataSource setLoadMoreCell:[self createLoadMoreCell]];
		
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

- (UITableViewCell *)createLoadMoreCell
{
	UITableViewCell * loadMoreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
	[loadMoreCell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	UIActivityIndicatorView * loadingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[loadingActivity setCenter:loadMoreCell.center];
	[loadingActivity startAnimating];
	[loadMoreCell.contentView addSubview:loadingActivity];
	
	return loadMoreCell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"%d %d", indexPath.section, indexPath.row);
//	if (indexPath.section == [self.dataSource sectionsCount]) {
//		[self.downloadController loadMore];
//	}
}

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	NSIndexPath *indexPath =[[self.tableView indexPathsForVisibleRows] lastObject];
	// если это ячейка loadMore
	if (indexPath.section == [self.dataSource sectionsCount]) {
		// запускаем догрузку
		[self.downloadController loadMore];
	}
}

#pragma mark - Download controller delegate

- (void)controller:(RIDownloadController *)controller didFinishLoadWithResponse:(id)response
{
    [self.refreshControl endRefreshing];
	self.dataSource.hasMore = self.downloadController.hasMore;
}

- (void)controller:(RIDownloadController *)controller didFailLoadWithError:(NSError *)error
{
    [self.refreshControl endRefreshing];
}

@end
