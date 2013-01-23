//
//  RISwipeMenuController.h
//  TwitterTimelineSample
//
//  Created by Ali Gadzhiev on 12/21/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RISlideMenuController : UIViewController

@property (nonatomic, strong) UIViewController * leftMenuController;
@property (nonatomic, strong) UIViewController * rightMenuController;
@property (nonatomic, strong) UIViewController * contentController;

@property (nonatomic) BOOL leftMenuHidden;
@property (nonatomic) BOOL rightMenuHidden;

- (void)setLeftMenuHidden:(BOOL)hidden animated:(BOOL)animated;

@end
