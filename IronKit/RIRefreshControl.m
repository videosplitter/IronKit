//
//  RIRefreshControl.m
//  TableViewDataSourceSample
//
//  Created by Ali Gadzhiev on 12/20/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import <objc/runtime.h>

#import "RIRefreshControl.h"

static CGFloat const kMaxInset				= 60.0;
static CGFloat const kFastAnimationDuration	= 0.2;

@interface RIRefreshControl ()

@property (nonatomic, readwrite, weak) UIScrollView * scrollView;

@end

@implementation RIRefreshControl

- (void)commonInit {
	_layout = RIRefrechControlLayoutTop;
	
	_textLabel = [[UILabel alloc] init];
	_textLabel.text = NSLocalizedString(@"Pull to refresh...", nil);
	_textLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:_textLabel];
	
	[self addObserver:self forKeyPath:@"scrollView.contentOffset" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"scrollView.frame" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
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

- (void)_updateFrame {
	CGSize scrollSize = _scrollView.frame.size;
	CGSize contentSize = _scrollView.contentSize;
	switch (_layout) {
		case RIRefrechControlLayoutTop: {
			self.frame = (CGRect) {CGPointMake(0.0, -scrollSize.height), scrollSize};
			break;
		}
		case RIRefrechControlLayoutLeft: {
			self.frame = (CGRect) {CGPointMake(-scrollSize.width, 0.0), scrollSize};
			break;
		}
		case RIRefrechControlLayoutBottom: {
			self.frame = (CGRect) {CGPointMake(0.0, contentSize.height + scrollSize.height), scrollSize};
			break;
		}
		case RIRefrechControlLayoutRight: {
			self.frame = (CGRect) {CGPointMake(contentSize.width + scrollSize.width, 0.0), scrollSize};
			break;
		}
	}
	[self setNeedsLayout];
}

#pragma mark - Public methods

- (void)beginRefreshing {
	if (_refreshing) return;
	_refreshing = YES;
	_textLabel.text = NSLocalizedString(@"Refreshing...", nil);
	[self setNeedsLayout];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	
	if (_scrollView.dragging) return;
	
	CGFloat offset = MAX(_scrollView.contentOffset.y * -1, 0);
	offset = MIN(offset, kMaxInset);
	[UIView animateWithDuration:kFastAnimationDuration animations:^{
		_scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
	}];
}

- (void)endRefreshing {
	_refreshing = NO;
	_textLabel.text = NSLocalizedString(@"Pull to refresh...", nil);
	[self setNeedsLayout];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	
	[UIView animateWithDuration:kFastAnimationDuration animations:^{
		_scrollView.contentInset = UIEdgeInsetsZero;
	}];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"scrollView.frame"] || [keyPath isEqualToString:@"scrollView.contentSize"]) {
		[self _updateFrame];
	} else if ([keyPath isEqualToString:@"scrollView.contentOffset"]) {
		switch (_layout) {
			case RIRefrechControlLayoutTop: {
				if (_refreshing && !_scrollView.dragging) {
					CGFloat offset = MAX(_scrollView.contentOffset.y * -1, 0);
					offset = MIN(offset, kMaxInset);
					[UIView animateWithDuration:kFastAnimationDuration animations:^{
						_scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
					}];
				} else {
					if (_scrollView.contentOffset.y < -kMaxInset) {
						[self beginRefreshing];
					}
				}
				break;
			}
			case RIRefrechControlLayoutLeft: {
				break;
			}
			case RIRefrechControlLayoutBottom: {
				break;
			}
			case RIRefrechControlLayoutRight: {
				break;
			}
		}
	}
}

#pragma mark - Layout

- (void)layoutSubviews {
	[_textLabel sizeToFit];
	switch (_layout) {
		case RIRefrechControlLayoutTop: {
			_textLabel.center = CGPointMake(CGRectGetMidX(self.bounds), self.bounds.size.height - kMaxInset/2.0);
			break;
		}
		case RIRefrechControlLayoutLeft: {
			break;
		}
		case RIRefrechControlLayoutBottom: {
			break;
		}
		case RIRefrechControlLayoutRight: {
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
