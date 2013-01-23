//
//  RIContentViewController.m
//  TwitterTimelineSample
//
//  Created by Ali Gadzhiev on 12/22/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RIContentViewController.h"

#import "RISlideMenuController.h"

@interface RIContentViewController ()

@end

@implementation RIContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(menuButtonPressed)];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)menuButtonPressed {
	RISlideMenuController * swipMenuController = (RISlideMenuController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
	[swipMenuController setLeftMenuHidden:!swipMenuController.leftMenuHidden animated:YES];
}

@end
