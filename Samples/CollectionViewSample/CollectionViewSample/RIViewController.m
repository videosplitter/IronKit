//
//  RIViewController.m
//  CollectionViewSample
//
//  Created by Ali Gadzhiev on 1/10/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import "RIViewController.h"
#import "RICollectionView.h"

@interface RIViewController () <RICollectionViewDataSource> {
    NSInteger _numberOfItemsInFirstSection;
    NSInteger _numberOfItemsInSecondSection;
    CGFloat _colorCorrection;
}
@property (weak, nonatomic) IBOutlet RICollectionView	* collectionView;

@end

@implementation RIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
    _numberOfItemsInFirstSection = 10;
    _numberOfItemsInSecondSection = 20;
	
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
	[self.collectionView registerClass:[RICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
	[self.collectionView reloadData];
    
//    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    button.frame = CGRectMake(50, 50, 100, 50);
//    [button setTitle:@"Reload section" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(reloadSectionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)reloadSectionButtonPressed {
//    _numberOfItemsInSecondSection += 10;
//    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
    
//    _colorCorrection += 10;
//    NSArray * indexPaths = [NSArray arrayWithObjects:
//                            [NSIndexPath indexPathForRow:5 inSection:1],
//                            [NSIndexPath indexPathForRow:3 inSection:0],
//                            [NSIndexPath indexPathForRow:7 inSection:2],
//                            nil];
//    [_collectionView reloadItemsAtIndexPaths:indexPaths];
    
    NSInteger numberOfItems = _numberOfItemsInFirstSection;
    _numberOfItemsInFirstSection = _numberOfItemsInSecondSection;
    _numberOfItemsInSecondSection = numberOfItems;
    [self.collectionView moveSection:0 toSection:1];
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(RICollectionView *)collectionView {
	return 2;
}

- (NSInteger)collectionView:(RICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 0;
    switch (section)
    {
        case 0:
        {
            numberOfItems = _numberOfItemsInFirstSection;
            break;
        }
            
        case 1:
        {
            numberOfItems = _numberOfItemsInSecondSection;
            break;
        }
    }
    return numberOfItems;
}

- (RICollectionViewCell *)collectionView:(RICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:indexPath.section * 100.0 / 255.0 green:indexPath.row * 5.0 / 255.0 blue:255.0 / 255.0 alpha:1.0];
	return cell;
}

@end
