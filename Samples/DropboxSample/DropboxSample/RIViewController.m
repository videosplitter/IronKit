//
//  RIViewController.m
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/25/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RIViewController.h"
#import "DBFetchModel.h"

@interface RIViewController ()

@property (strong, nonatomic) DBFetchModel * model;

@end

@implementation RIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.model = [DBFetchModel model];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	if ([[DBSession sharedSession] isLinked]) {
		[self.model load];
	} else {
		[[DBSession sharedSession] linkFromController:self];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)dbSessionDidChange {
}

@end
