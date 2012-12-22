//
//  RILeftMenuViewController.m
//  TwitterTimelineSample
//
//  Created by Ali Gadzhiev on 12/22/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RILeftMenuViewController.h"
#import "RIContentViewController.h"
#import "RISlideMenuController.h"

@interface RILeftMenuViewController () {
	UIViewController * _redContentController;
	UIViewController * _greenContentController;
	UIViewController * _blueContentController;
}

@end

@implementation RILeftMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	RIContentViewController * redContentController = [[RIContentViewController alloc] init];
	redContentController.view.backgroundColor = [UIColor redColor];
	_redContentController = [[UINavigationController alloc] initWithRootViewController:redContentController];
	
	RIContentViewController * greenContentController = [[RIContentViewController alloc] init];
	greenContentController.view.backgroundColor = [UIColor greenColor];
	_greenContentController = [[UINavigationController alloc] initWithRootViewController:greenContentController];
	
	RIContentViewController * blueContentController = [[RIContentViewController alloc] init];
	blueContentController.view.backgroundColor = [UIColor blueColor];
	_blueContentController = [[UINavigationController alloc] initWithRootViewController:blueContentController];
}

- (void)viewDidUnload {
	_redContentController = nil;
	_greenContentController = nil;
	_blueContentController = nil;
	[super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	switch (indexPath.row) {
		case 0: {
			cell.textLabel.text = @"Red";
			break;
		}
		case 1: {
			cell.textLabel.text = @"Green";
			break;
		}
		case 2: {
			cell.textLabel.text = @"Blue";
			break;
		}
	}
	
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	RISlideMenuController * swipeMenuController = (RISlideMenuController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
	switch (indexPath.row) {
		case 0: {
			swipeMenuController.contentController = _redContentController;
			break;
		}
		case 1: {
			swipeMenuController.contentController = _blueContentController;
			break;
		}
		case 2: {
			swipeMenuController.contentController = _greenContentController;
			break;
		}
	}
}

@end
