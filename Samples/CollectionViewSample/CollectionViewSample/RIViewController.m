//
//  RIViewController.m
//  CollectionViewSample
//
//  Created by Ali Gadzhiev on 1/10/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import "RIViewController.h"
#import "RICollectionView.h"
#import "RICollectionViewCell.h"

@interface RIViewController () <RICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet RICollectionView	* collectionView;

@end

@implementation RIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[_collectionView registerClass:[RICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
	[_collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(RICollectionView *)collectionView {
	return 2;
}

- (NSInteger)collectionView:(RICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return section == 0 ? 60 : 60;
}

- (RICollectionViewCell *)collectionView:(RICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:indexPath.row * 1 / 255.0 green:indexPath.row * 2 / 255.0 blue:indexPath.row * 3 / 255.0 alpha:1.0];
	return cell;
}

@end
