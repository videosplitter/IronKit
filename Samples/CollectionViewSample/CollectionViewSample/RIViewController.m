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

@interface RIViewController () <RICollectionViewDataSource> {
    NSInteger _numberOfItemsInSecondSection;
    CGFloat _colorCorrection;
}
@property (weak, nonatomic) IBOutlet RICollectionView	* collectionView;

@end

@implementation RIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
    _numberOfItemsInSecondSection = 20;
	
    self.collectionView.allowsMultipleSelection = YES;
	[self.collectionView registerClass:[RICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
	[self.collectionView reloadData];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(50, 50, 100, 50);
    [button setTitle:@"Reload section" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(reloadSectionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
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
    [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]];
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(RICollectionView *)collectionView {
	return 3;
}

- (NSInteger)collectionView:(RICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 0;
    switch (section) {
        case 0: {
            numberOfItems = 10;
            break;
        }
        case 1: {
            numberOfItems = _numberOfItemsInSecondSection;
            break;
        }
        case 2: {
            numberOfItems = 50;
            break;
        }
        default:
            break;
    }
	return numberOfItems;
}

- (RICollectionViewCell *)collectionView:(RICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0: {
            cell.backgroundColor = [UIColor colorWithRed:(indexPath.row * 1 + _colorCorrection) / 255.0 green:1.0 blue:1.0 alpha:1.0];
            break;
        }
            
        case 1: {
            cell.backgroundColor = [UIColor colorWithRed:1.0 green:(indexPath.row * 2 + _colorCorrection) / 255.0 blue:1.0 alpha:1.0];
            break;
        }
            
        case 2: {
            cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:(indexPath.row * 3 + _colorCorrection) / 255.0 alpha:1.0];
            break;
        }
            
        default:
            break;
    }
    
	return cell;
}

@end
