//
//  RICollectionView.m
//  CollectionViewSample
//
//  Created by Ali Gadzhiev on 1/10/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import "RICollectionView.h"


@interface RICollectionView () {
	// Store sections frames in collection view coordinate system
	NSMutableArray		* _sectionsFrames;
	// Store items frames in section coordinate system
	NSMutableArray		* _itemsFrames;
	
	NSMutableDictionary	* _registredCellClasses;
}

@end

@implementation RICollectionView

- (void)_init {
	_itemSize = CGSizeMake(50.0, 50.0);
	
	_allowsSelection = YES;
	_allowsMultipleSelection = NO;
	
	_registredCellClasses = [NSMutableDictionary dictionary];
	
	_itemsFrames = [NSMutableArray array];
	_sectionsFrames = [NSMutableArray array];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self _init];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self _init];
	}
	return self;
}

#pragma mark - Registred cell classes

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
	NSAssert(identifier, @"Identifier can not be nil");
	[_registredCellClasses setObject:NSStringFromClass(cellClass) forKey:identifier];
}

- (Class)_classForCellWithReuseIdentifier:(NSString *)identifier {
	return NSClassFromString([_registredCellClasses objectForKey:identifier]);
}

#pragma mark - Reloading

- (void)_reloadSection:(NSInteger)section {
	CGSize boundsSize = self.bounds.size;
	int itemsInRow = 0;
	
	switch (self.scrollDirection) {
		case RICollectionViewScrollDirectionVertical: {
			itemsInRow = boundsSize.width / _itemSize.width;
			break;
		}
		case RICollectionViewScrollDirectionHorizontal: {
			itemsInRow = boundsSize.height / _itemSize.height;
			break;
		}
	}
	
	NSInteger numberOfItems = [self.dataSource collectionView:self numberOfItemsInSection:section];
	NSMutableArray * itemsFrames = [NSMutableArray arrayWithCapacity:numberOfItems];
	CGPoint origin = CGPointZero;
	for (unsigned item = 0; item < numberOfItems; ++item) {
//		switch (self.scrollDirection) {
//			case RICollectionViewScrollDirectionVertical: {
//				row = item / ();
//				origin.x += _itemSize.width;
//				if (origin.x > boundsSize.width) {
//					origin.x = 0;
//					origin.y += _itemSize.height;
//				}
//				break;
//			}
//			case RICollectionViewScrollDirectionHorizontal: {
//				origin.y += _itemSize.height;
//				if (origin.y > boundsSize.height) {
//					origin.x += _itemSize.width;
//					origin.y = 0;
//				}
//				break;
//			}
//		}
		
		switch (self.scrollDirection) {
			case RICollectionViewScrollDirectionVertical: {
				origin.x = item / itemsInRow;
				origin.y = item % itemsInRow;
				break;
			}
			case RICollectionViewScrollDirectionHorizontal: {
				origin.x = item % itemsInRow;
				origin.y = item / itemsInRow;
				break;
			}
		}
		
		CGRect itemFrame = {origin, _itemSize};
		[itemsFrames addObject:[NSValue value:&itemFrame withObjCType:@encode(CGRect)]];
	}
	
	CGRect sectionFrame = CGRectZero;
	if (section > 0) {
		// Set current section frame.origin from previous section frame
		CGRect previousSectionFrame;
		NSValue * value = [_sectionsFrames objectAtIndex:section - 1];
		[value getValue:&previousSectionFrame];
		
		switch (self.scrollDirection) {
			case RICollectionViewScrollDirectionVertical: {
				sectionFrame.origin.x = previousSectionFrame.origin.x;
				sectionFrame.origin.y = CGRectGetMaxY(previousSectionFrame);
				break;
			}
			case RICollectionViewScrollDirectionHorizontal: {
				sectionFrame.origin.x = CGRectGetMaxX(previousSectionFrame);
				sectionFrame.origin.y = previousSectionFrame.origin.y;
				break;
			}
		}
	}
	
	CGRect lastItemFrame;
	[(NSValue *)[itemsFrames lastObject] getValue:&lastItemFrame];
	switch (self.scrollDirection) {
		case RICollectionViewScrollDirectionVertical: {
			sectionFrame.size.width = boundsSize.width;
			sectionFrame.size.height = CGRectGetMaxY(lastItemFrame);
			break;
		}
		case RICollectionViewScrollDirectionHorizontal: {
			sectionFrame.size.width = CGRectGetMaxX(lastItemFrame);
			sectionFrame.size.height = boundsSize.height;
			break;
		}
	}
	
	[_sectionsFrames replaceObjectAtIndex:section withObject:[NSValue value:&sectionFrame withObjCType:@encode(CGRect)]];
	[_itemsFrames replaceObjectAtIndex:section withObject:itemsFrames];
}

- (void)reloadData {
	[_sectionsFrames removeAllObjects];
	[_itemsFrames removeAllObjects];
	
	NSInteger numberOfSections = 1;
	if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
		numberOfSections = [self.dataSource numberOfSectionsInCollectionView:self];
	}
	
	for (unsigned section = 0; section < numberOfSections; ++section) {
		[_sectionsFrames addObject:[NSMutableArray array]];
		[_itemsFrames addObject:[NSMutableArray array]];
		
		[self _reloadSection:section];
	}
	
	NSLog(@"%@", _sectionsFrames);
	NSLog(@"%@", _itemsFrames);
}

- (void)reloadSections:(NSIndexSet *)sections {
//	for (unsigned section = 0; section < numberOfSections; ++section) {
//		[self _reloadSection:];
//	}
}

@end
