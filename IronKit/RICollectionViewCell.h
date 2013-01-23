//
//  RICollectionViewCell.h
//  CollectionViewSample
//
//  Created by Ali Gadzhiev on 1/10/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RICollectionViewCell : UIView

@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@property (nonatomic, readonly, copy) NSString * reuseIdentifier;
@property (nonatomic, readonly, strong) UIView * contentView;
@property (nonatomic, strong) UIView * backgroundView;
@property (nonatomic, strong) UIView * selectedBackgroundView;

- (void)prepareForReuse;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@end
