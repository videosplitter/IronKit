//
//  RICollectionViewCell.m
//  CollectionViewSample
//
//  Created by Ali Gadzhiev on 1/10/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import "RICollectionViewCell.h"

@implementation RICollectionViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super init];
    if (self) {
        _reuseIdentifier = [reuseIdentifier copy];
    }
    return self;
}

@end
