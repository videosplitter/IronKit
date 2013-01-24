//
//  RIRefreshControl.m
//  TableViewDataSourceSample
//
//  Created by Ali Gadzhiev on 12/20/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import <objc/runtime.h>

#import "RIRefreshControl.h"

static CGFloat const kMaxInset				= 70.0;
static CGFloat const kFastAnimationDuration	= 0.2;

@interface RIRefreshControl ()
{
    UIView * _activityIndicator;
    UILabel * _textLabel;
}

@property (nonatomic, strong) UIImageView * arrowImageView;
@property (nonatomic, readwrite, weak) UIScrollView * scrollView;
@property (nonatomic, readwrite, getter = isRefreshing) BOOL refreshing;

@end

@implementation RIRefreshControl

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"scrollView.contentOffset"];
    [self removeObserver:self forKeyPath:@"scrollView.frame"];
    [self removeObserver:self forKeyPath:@"scrollView.contentSize"];
}

- (void)_init
{
    self.backgroundColor = [UIColor clearColor];
	self.layout = RIRefrechControlLayoutTop;
	
	[self addObserver:self forKeyPath:@"scrollView.contentOffset" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"scrollView.frame" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
    {
		[self _init];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
    {
		[self _init];
	}
	return self;
}

- (void)setLayout:(RIRefrechControlLayout)layout {
	if (_layout == layout) return;
	[self willChangeValueForKey:@"layout"];
	_layout = layout;
	[self _updateFrame];
	[self didChangeValueForKey:@"layout"];
}

- (void)setScrollView:(UIScrollView *)scrollView {
	if (_scrollView == scrollView) return;
	
	[self willChangeValueForKey:@"scrollView"];
	_scrollView = scrollView;
	[self _updateFrame];
	
	[self didChangeValueForKey:@"scrollView"];
}

- (void)setArrowImage:(UIImage *)image
{
    self.arrowImageView.image = image;
    [self.arrowImageView sizeToFit];
    [self setNeedsLayout];
}

- (UIImage *)arrowImage
{
    return self.arrowImageView.image;
}

- (UIImageView *)arrowImageView
{
    if (!_arrowImageView)
    {
        _arrowImageView = [[UIImageView alloc] init];
        [self addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (UILabel *)textLabel
{
    if (!_textLabel)
    {
        UILabel * textLabel = [[UILabel alloc] init];
        textLabel.text = NSLocalizedString(@"Pull to refresh...", nil);
        textLabel.backgroundColor = [UIColor clearColor];
        _textLabel = textLabel;
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

- (UIView *)activityIndicator
{
    if (!_activityIndicator)
    {
        UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.hidesWhenStopped = YES;
        self.activityIndicator = activityView;
    }
    return _activityIndicator;
}

- (void)setActivityIndicator:(UIView *)view
{
    if (_activityIndicator == view) return;
    
    [self willChangeValueForKey:@"activityIndicator"];
    [_activityIndicator removeFromSuperview];
    _activityIndicator = view;
    if (_activityIndicator)
    {
        [self addSubview:_activityIndicator];
    }
    
    if (self.refreshing)
    {
        if ([self.activityIndicator respondsToSelector:@selector(startAnimating)])
        {
            [self.activityIndicator performSelector:@selector(startAnimating)];
        }
        else
        {
            self.activityIndicator.hidden = NO;
        }
    }
    else
    {
        if ([self.activityIndicator respondsToSelector:@selector(stopAnimating)])
        {
            [self.activityIndicator performSelector:@selector(stopAnimating)];
        }
        else
        {
            self.activityIndicator.hidden = YES;
        }
    }
    
    [self setNeedsLayout];
    [self willChangeValueForKey:@"activityIndicator"];
}

- (void)_updateFrame {
	CGSize scrollSize = _scrollView.frame.size;
	CGSize contentSize = _scrollView.contentSize;
	switch (self.layout)
    {
		case RIRefrechControlLayoutTop:
        {
			self.frame = (CGRect) {CGPointMake(0.0, -scrollSize.height), scrollSize};
			break;
		}
		case RIRefrechControlLayoutLeft:
        {
			self.frame = (CGRect) {CGPointMake(-scrollSize.width, 0.0), scrollSize};
			break;
		}
		case RIRefrechControlLayoutBottom:
        {
			self.frame = (CGRect) {CGPointMake(0.0, contentSize.height + scrollSize.height), scrollSize};
			break;
		}
		case RIRefrechControlLayoutRight:
        {
			self.frame = (CGRect) {CGPointMake(contentSize.width + scrollSize.width, 0.0), scrollSize};
			break;
		}
	}
	[self setNeedsLayout];
}

#pragma mark - Public methods

- (void)beginRefreshing
{
	if (self.refreshing) return;
	self.refreshing = YES;
    
	self.textLabel.text = NSLocalizedString(@"Refreshing...", nil);
	
    if ([self.activityIndicator respondsToSelector:@selector(startAnimating)])
    {
        [self.activityIndicator performSelector:@selector(startAnimating)];
    }
	[UIView animateWithDuration:kFastAnimationDuration animations:^{
        if (!self.scrollView.dragging)
        {
            CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
            offset = MIN(offset, kMaxInset);
            self.scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        }
		
        self.arrowImageView.alpha = 0.0;
        if (![self.activityIndicator respondsToSelector:@selector(startAnimating)])
        {
            self.activityIndicator.alpha = 0.0;
        }
	}];
    
    [self setNeedsLayout];
}

- (void)endRefreshing
{
    if (!self.refreshing) return;
    
	self.textLabel.text = NSLocalizedString(@"Pull to refresh...", nil);
    if ([self.activityIndicator respondsToSelector:@selector(stopAnimating)])
    {
        [self.activityIndicator performSelector:@selector(stopAnimating)];
    }
	
	[UIView animateWithDuration:kFastAnimationDuration animations:^{
		self.scrollView.contentInset = UIEdgeInsetsZero;
        self.scrollView.contentOffset = CGPointZero;
        self.arrowImageView.alpha = 1.0;
        if (![self.activityIndicator respondsToSelector:@selector(stopAnimating)])
        {
            self.activityIndicator.alpha = 1.0;
        }
	} completion:^(BOOL finished) {
        self.refreshing = NO;
    }];
    [self setNeedsLayout];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"scrollView.frame"] || [keyPath isEqualToString:@"scrollView.contentSize"])
    {
		[self _updateFrame];
	}
    else if ([keyPath isEqualToString:@"scrollView.contentOffset"])
    {
		switch (self.layout)
        {
			case RIRefrechControlLayoutTop:
            {
				if (self.refreshing && !self.scrollView.dragging)
                {
					CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
					offset = MIN(offset, kMaxInset);
					[UIView animateWithDuration:kFastAnimationDuration animations:^{
						self.scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
					}];
                    break;
				}
                
                if (self.scrollView.dragging && self.scrollView.contentOffset.y < -kMaxInset)
                {
                    if (!self.refreshing)
                    {
                        [self beginRefreshing];
                        [self sendActionsForControlEvents:UIControlEventValueChanged];
                    }
                }
				break;
			}
			case RIRefrechControlLayoutLeft:
            {
				break;
			}
			case RIRefrechControlLayoutBottom:
            {
				break;
			}
			case RIRefrechControlLayoutRight:
            {
				break;
			}
		}
	}
}

#pragma mark - Layout

- (void)layoutSubviews
{
	[self.textLabel sizeToFit];
	switch (self.layout)
    {
		case RIRefrechControlLayoutTop:
        {
            self.arrowImageView.center =
            self.activityIndicator.center = CGPointMake(kMaxInset/2.0, self.bounds.size.height - kMaxInset/2.0);
			self.textLabel.center = CGPointMake(CGRectGetMidX(self.bounds), self.bounds.size.height - kMaxInset/2.0);
			break;
		}
		case RIRefrechControlLayoutLeft:
        {
			break;
		}
		case RIRefrechControlLayoutBottom:
        {
			break;
		}
		case RIRefrechControlLayoutRight:
        {
			break;
		}
	}
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

static char RIScrollViewRefrechControlObjectKey;

@implementation UIScrollView (RIRefrechControl)

- (void)setRefreshControl:(RIRefreshControl *)refreshControl {
	RIRefreshControl * _refrechControl = [self refreshControl];
	if (_refrechControl == refreshControl) return;
	
	_refrechControl.scrollView = nil;
	[_refrechControl removeFromSuperview];
	
	objc_setAssociatedObject(self, &RIScrollViewRefrechControlObjectKey, refreshControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	refreshControl.scrollView = self;
	[self addSubview:refreshControl];
	
}

- (RIRefreshControl *)refreshControl {
	return (RIRefreshControl *)objc_getAssociatedObject(self, &RIScrollViewRefrechControlObjectKey);;
}

@end
