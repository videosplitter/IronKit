//
//  RIRootViewController.m
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/26/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RIRootViewController.h"
#import "DBFetchModel.h"
#import "DBFile.h"

#import "RITableViewDataSource.h"

@interface RIRootViewController () {
	RITableViewDataSource * _dataSource;
}
@property (strong, nonatomic) DBFetchModel * model;
@property (strong, nonatomic) UITableView * tableView;
@end

@implementation RIRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.model = [DBFetchModel model];
		
		_dataSource = [[RITableViewDataSource alloc] init];
		_dataSource.fetchedResults = [DBFile MR_fetchAllGroupedBy:nil withPredicate:nil sortedBy:@"modified" ascending:YES];
		[_dataSource registerClass:[UITableViewCell class] forCellWithReuseIdentifier:@"Cell"];
		[_dataSource setReusableIdentifierBlock:^NSString *(NSIndexPath * indexPath) {
			return @"Cell";
		}];
		[_dataSource setConfigureCellBlock:^(UITableViewCell * cell, NSIndexPath * indexPath, id obj) {
			DBFile * file = obj;
			cell.textLabel.text = [file.path stringByStandardizingPath];
		}];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.tableView];
	
	_dataSource.tableView = self.tableView;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([[DBSession sharedSession] isLinked]) {
		[self.model load];
	} else {
		[[DBSession sharedSession] linkFromController:self];
	}
}

@end
