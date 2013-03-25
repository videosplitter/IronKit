//
//  RIInfinityTableViewDataSource.h
//  TwitterTimelineSample
//
//  Created by DenGun on 25.03.13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import "RITableViewDataSource.h"

@interface RIInfinityTableViewDataSource : RITableViewDataSource
@property (nonatomic, strong) UITableViewCell * loadMoreCell;
@property (nonatomic) BOOL hasMore;
- (NSInteger)sectionsCount;
@end
