//
//  RICollectionViewCell.h
//  CollectionViewSample
//
//  Created by Ali Gadzhiev on 1/10/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RICollectionViewCell : UIView

@property (nonatomic, readonly, copy) NSString * reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
