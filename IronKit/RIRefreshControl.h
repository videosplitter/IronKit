//
//  RIRefreshControl.h
//  TableViewDataSourceSample
//
//  Created by Ali Gadzhiev on 12/20/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RIRefrechControlLayout) {
	RIRefrechControlLayoutTop,
	RIRefrechControlLayoutLeft,
	RIRefrechControlLayoutBottom,
	RIRefrechControlLayoutRight
};

@interface RIRefreshControl : UIControl

@property (nonatomic) RIRefrechControlLayout layout;
@property (nonatomic, strong) UIView * activityIndicator;
@property (nonatomic, readonly, weak) UIScrollView * scrollView;
@property (nonatomic, readonly) UILabel * textLabel;
@property (nonatomic, readonly, getter = isRefreshing) BOOL refreshing;

- (void)beginRefreshing;
- (void)endRefreshing;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIScrollView (RIRefrechControl)

@property (nonatomic, strong) RIRefreshControl * refreshControl;

@end
