//
//  RICollectionViewCell.m
//  CollectionViewSample
//
//  Created by Ali Gadzhiev on 1/10/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import "RICollectionViewCell.h"

@interface RICollectionViewCell ()

@property (nonatomic, readwrite, copy) NSString * reuseIdentifier;
@property (nonatomic, readwrite, strong) UIView * contentView;

@end

@implementation RICollectionViewCell

- (void)_commonInit {
    UIView * view = [[UIView alloc] initWithFrame:self.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentView = view;
    [self addSubview:self.contentView];
    
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    selectedBackgroundView.backgroundColor = [UIColor blueColor];
    self.selectedBackgroundView = selectedBackgroundView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _commonInit];
    }
    return self;
}

- (void)prepareForReuse {
    
}

- (void)setBackgroundView:(UIView *)view
{
    if (view != _backgroundView)
    {
        [_backgroundView removeFromSuperview];
        _backgroundView = view;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (_backgroundView)
        {
            if (!self.selected && !self.highlighted)
            {
                _backgroundView.frame = self.bounds;
                [self insertSubview:_backgroundView belowSubview:self.contentView];
            }
        }
    }
}

- (void)setSelectedBackgroundView:(UIView *)view
{
    if (view != _selectedBackgroundView)
    {
        [_selectedBackgroundView removeFromSuperview];
        _selectedBackgroundView = view;
        _selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (_selectedBackgroundView)
        {
            if (self.selected || self.highlighted)
            {
                _selectedBackgroundView.frame = self.bounds;
                [self insertSubview:_selectedBackgroundView belowSubview:self.contentView];
            }
        }
    }
}

#pragma mark - Selecting

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (_selected != selected)
    {
        _selected = selected;
        
        if (_selected)
        {
            self.selectedBackgroundView.frame = self.bounds;
            self.selectedBackgroundView.alpha = 0.0;
            [self insertSubview:self.selectedBackgroundView belowSubview:self.contentView];
        }
        else
        {
            self.backgroundView.frame = self.bounds;
            [self insertSubview:self.backgroundView belowSubview:self.contentView];
        }
        [UIView animateWithDuration:animated ? 0.2 : 0.0 animations:^{
            self.selectedBackgroundView.alpha = (_selected) ? 1.0 : 0.0;
        } completion:^(BOOL finished) {
            if (_selected)
            {
                [self.backgroundView removeFromSuperview];
            }
            else
            {
                [self.selectedBackgroundView removeFromSuperview];
            }
        }];
    }
}

#pragma mark - Highlighting

- (void)setHighlighted:(BOOL)highlighted
{
    [self setHighlighted:highlighted animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (_highlighted != highlighted)
    {
        _highlighted = highlighted;
        if (_highlighted)
        {
            self.selectedBackgroundView.frame = self.bounds;
            self.selectedBackgroundView.alpha = 0.0;
            [self insertSubview:self.selectedBackgroundView belowSubview:self.contentView];
        }
        else
        {
            self.backgroundView.frame = self.bounds;
            self.backgroundView.alpha = 0.0;
            [self insertSubview:self.backgroundView belowSubview:self.contentView];
        }
        [UIView animateWithDuration:animated ? 0.2 : 0.0 animations:^{
            if (_highlighted)
            {
                self.selectedBackgroundView.alpha = 1.0;
            }
            else
            {
                self.backgroundView.alpha = 1.0;
            }
        } completion:^(BOOL finished) {
            if (_highlighted)
            {
                [self.backgroundView removeFromSuperview];
            }
            else
            {
                [self.selectedBackgroundView removeFromSuperview];
            }
        }];
    }
}

@end
