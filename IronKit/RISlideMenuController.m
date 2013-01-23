//
//  RISwipeMenuController.m
//  TwitterTimelineSample
//
//  Created by Ali Gadzhiev on 12/21/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import "RISlideMenuController.h"

NSTimeInterval const kTransitionDuration	= 0.3;

CGFloat const kLedgeWidth					= 70.0;

CGFloat const kVelocityThreshold			= 1500.0;

@interface RISlideMenuController () <UIGestureRecognizerDelegate> {
	UIPanGestureRecognizer * _draggingGestureRecognizer;
	UITapGestureRecognizer * _tapGestureRecognizer;
	
	CGRect _startDraggingFrame;
}

@end

@implementation RISlideMenuController

- (void)commonInit {
	_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
	_tapGestureRecognizer.delegate = self;
	_draggingGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragging)];
	[_draggingGestureRecognizer requireGestureRecognizerToFail:_tapGestureRecognizer];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_leftMenuHidden = YES;
	_rightMenuHidden = YES;
	
	CGRect frame = self.view.bounds;
	if (_contentController) {
		_contentController.view.frame = frame;
		[self.view addSubview:_contentController.view];
	} else if (_leftMenuController) {
		_leftMenuController.view.frame = frame;
		[self.view addSubview:_leftMenuController.view];
		_leftMenuHidden = NO;
	} else if (_rightMenuController) {
		_rightMenuController.view.frame = frame;
		[self.view addSubview:_rightMenuController.view];
		_rightMenuHidden = NO;
	}
	_tapGestureRecognizer.enabled = !_leftMenuHidden || !_rightMenuHidden;
	_contentController.view.userInteractionEnabled = !_tapGestureRecognizer.enabled;
	
	[self.view addGestureRecognizer:_draggingGestureRecognizer];
	[self.view addGestureRecognizer:_tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Controllers setters

- (void)setLeftMenuController:(UIViewController *)viewController {
	if (_leftMenuController == viewController) return;
	
	if ([self isViewLoaded]) {
		if (!_leftMenuHidden) {
			viewController.view.frame = _leftMenuController.view.frame;
			[self.view insertSubview:viewController.view belowSubview:_leftMenuController.view];
			[_leftMenuController.view removeFromSuperview];
		}
	}
	
	[self willChangeValueForKey:@"leftMenuController"];
	_leftMenuController = viewController;
	[self didChangeValueForKey:@"leftMenuController"];
}

- (void)setContentController:(UIViewController *)viewController {
	if (_contentController == viewController) {
		if (!_leftMenuHidden) {
			[self setLeftMenuHidden:YES animated:YES];
		}
		return;
	}
	
	if ([self isViewLoaded]) {
		CGRect bounds = self.view.bounds;
		if (_leftMenuHidden) {
			viewController.view.frame = _contentController ? _contentController.view.frame : bounds;
			[self.view insertSubview:viewController.view belowSubview:_contentController.view];
			[_contentController.view removeFromSuperview];
		} else {
			viewController.view.frame = _contentController ? _contentController.view.frame : CGRectOffset(bounds, bounds.size.width, 0.0);
			[self.view insertSubview:viewController.view aboveSubview:_leftMenuController.view];
			[UIView animateWithDuration:kTransitionDuration animations:^{
				viewController.view.frame = bounds;
			} completion:^(BOOL finished) {
				[_leftMenuController.view removeFromSuperview];
				_leftMenuHidden = YES;
			}];
			[_contentController.view removeFromSuperview];
		}
	}
	
	[self willChangeValueForKey:@"contentController"];
	_contentController = viewController;
	[self didChangeValueForKey:@"contentController"];
}

#pragma mark - Left menu showing/hidding

- (void)setLeftMenuHidden:(BOOL)hidden {
	[self setLeftMenuHidden:hidden animated:NO];
}

- (void)setLeftMenuHidden:(BOOL)hidden animated:(BOOL)animated {
	if (_leftMenuHidden == hidden) return;
	if (hidden && _contentController == nil) return;
	
	if (hidden) {
		CGRect bounds = self.view.bounds;
		
		[UIView animateWithDuration:kTransitionDuration animations:^{
			_contentController.view.frame = bounds;
		} completion:^(BOOL finished) {
			[_leftMenuController.view removeFromSuperview];
		}];
	} else {
		if (_contentController == nil) {
			_leftMenuController.view.frame = self.view.bounds;
			[self.view addSubview:_leftMenuController.view];
		} else {
			CGRect bounds = self.view.bounds;
			_leftMenuController.view.frame = (CGRect) { bounds.origin, { bounds.size.width - kLedgeWidth, bounds.size.height } };
			[self.view insertSubview:_leftMenuController.view belowSubview:_contentController.view];
			
			[UIView animateWithDuration:kTransitionDuration animations:^{
				_contentController.view.frame = CGRectOffset(bounds, bounds.size.width - kLedgeWidth, 0.0);
			}];
		}
	}
	_tapGestureRecognizer.enabled = !hidden;
	_contentController.view.userInteractionEnabled = !_tapGestureRecognizer.enabled;
	
	[self willChangeValueForKey:@"leftMenuHidden"];
	_leftMenuHidden = hidden;
	[self didChangeValueForKey:@"leftMenuHidden"];
}

#pragma mark - Gesture handlers

- (void)handleDragging {
	if (!_contentController) return;
	
	CGRect bounds = self.view.bounds;
	CGFloat rightBorder = bounds.size.width - kLedgeWidth;

	if (_draggingGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		_startDraggingFrame = _contentController.view.frame;
		
		_leftMenuController.view.frame = (CGRect) { bounds.origin, { bounds.size.width - kLedgeWidth, bounds.size.height } };
		[self.view insertSubview:_leftMenuController.view belowSubview:_contentController.view];
	}
	
	CGPoint translation = [_draggingGestureRecognizer translationInView:_contentController.view];
	CGRect contentFrame = CGRectOffset(_startDraggingFrame, translation.x, 0.0);
	if (contentFrame.origin.x < 0.0) {
		contentFrame.origin.x = 0.0;
	} else if (contentFrame.origin.x > rightBorder) {
		contentFrame.origin.x = rightBorder;
	}
	
	_contentController.view.frame = contentFrame;
	
	if (_draggingGestureRecognizer.state == UIGestureRecognizerStateEnded ||
		_draggingGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
		// Check velocity to indicate swipe gesture
		CGPoint velocity = [_draggingGestureRecognizer velocityInView:_contentController.view];
		if (fabsf(velocity.x) > kVelocityThreshold) {
			_leftMenuHidden = (velocity.x < 0);
		} else {
			_leftMenuHidden = (contentFrame.origin.x < (bounds.size.width / 2.0));
		}
		
		if (_leftMenuHidden) {
			_tapGestureRecognizer.enabled = NO;
			contentFrame.origin.x = 0.0;
		} else {
			_tapGestureRecognizer.enabled = YES;
			contentFrame.origin.x = rightBorder;
		}
		_contentController.view.userInteractionEnabled = !_tapGestureRecognizer.enabled;
			
		[UIView animateWithDuration:kTransitionDuration animations:^{
			_contentController.view.frame = contentFrame;
		} completion:^(BOOL finished) {
			if (_leftMenuHidden) {
				NSLog(@"removeFromSuperview");
				[_leftMenuController.view removeFromSuperview];
			}
		}];
	}

}

- (void)handleTap {
	if (!_contentController) return;
	
	[self setLeftMenuHidden:YES animated:YES];
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if (gestureRecognizer == _tapGestureRecognizer) {
		if (!CGRectContainsPoint(_contentController.view.bounds, [touch locationInView:_contentController.view])) {
			return NO;
		}
	}
	return YES;
}

@end
