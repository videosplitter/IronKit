//
//  RICollectionView.m
//  CollectionViewSample
//
//  Created by Ali Gadzhiev on 1/10/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import "RICollectionView.h"
#import "RICollectionViewCell.h"

@interface RICollectionView ()

// Store sections frames in collection view coordinate system
@property (strong, nonatomic) NSMutableArray * sectionsFrames;
// Store items frames in section coordinate system
@property (strong, nonatomic) NSMutableArray * itemsFrames;

@property (strong, nonatomic) NSMutableDictionary * registredCellClasses;

@property (copy, nonatomic) NSArray * indexPathsForVisibleItems;
@property (copy, nonatomic) NSArray * indexPathsForSelectedItems;

@property (strong, nonatomic) NSMutableDictionary * visibleCellsDictionary;
@property (strong, nonatomic) NSMutableDictionary * reusableCells;

@property (strong, nonatomic) UITapGestureRecognizer * tapGestureRecognizer;

@end

@implementation RICollectionView

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"bounds"];
}

- (void)_init {
	self.itemSize = CGSizeMake(50.0, 50.0);
	
	self.allowsSelection = YES;
	self.allowsMultipleSelection = NO;
	
	self.itemsFrames = [NSMutableArray array];
	self.sectionsFrames = [NSMutableArray array];
    
    self.registredCellClasses = [NSMutableDictionary dictionary];
    self.visibleCellsDictionary = [NSMutableDictionary dictionary];
    self.reusableCells = [NSMutableDictionary dictionary];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
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
    [self.reusableCells setObject:[NSMutableArray array] forKey:identifier];
	[self.registredCellClasses setObject:NSStringFromClass(cellClass) forKey:identifier];
}

- (Class)_classForCellWithReuseIdentifier:(NSString *)identifier {
	return NSClassFromString([self.registredCellClasses objectForKey:identifier]);
}

#pragma mark - Dequeuing

- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray * cells = [self.reusableCells objectForKey:identifier];
    if ([cells count] == 0) {
        return [[RICollectionViewCell alloc] initWithReuseIdentifier:identifier];
    }
    
    RICollectionViewCell * cell = [cells lastObject];
    [cells removeObject:cell];
    return cell;
}

#pragma mark - Reusing

- (void)_reuseCell:(RICollectionViewCell *)cell
{
    NSMutableArray * cells = [self.reusableCells objectForKey:cell.reuseIdentifier];
    [cells addObject:cell];
}

- (NSInteger)numberOfSections
{
    return [self.sectionsFrames count];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    return [(NSArray *)self.itemsFrames[section] count];
}

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point
{
    NSIndexPath * indexPath = nil;
    for (unsigned section = 0; section < [self.sectionsFrames count]; ++section)
    {
        CGRect sectionFrame;
        [(NSValue *)self.sectionsFrames[section] getValue:&sectionFrame];
        if (CGRectContainsPoint(sectionFrame, point))
        {
            NSArray * sectionItemsFrames = self.itemsFrames[section];
            for (unsigned item = 0; item < [sectionItemsFrames count]; ++item)
            {
                NSIndexPath * currentIndexPath = [NSIndexPath indexPathForRow:item inSection:section];
                CGRect itemFrame = [self _frameForCellAtIndexPath:currentIndexPath];
                if (CGRectContainsPoint(itemFrame, point))
                {
                    indexPath = currentIndexPath;
                    break;
                }
            }
            break;
        }
    }
    return indexPath;
}

- (NSIndexPath *)indexPathForCell:(RICollectionViewCell *)cell
{
    __block NSIndexPath * indexPath = nil;
    [self.visibleCellsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == cell)
        {
            indexPath = key;
            *stop = YES;
        }
    }];
    return indexPath;
}

#pragma mark - Selecting

- (void)handleTap
{
    switch (self.tapGestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath * indexPath = [self indexPathForItemAtPoint:[self.tapGestureRecognizer locationInView:self]];
            if (![self.indexPathsForSelectedItems containsObject:indexPath])
            {
                RICollectionViewCell * cell = [self.visibleCellsDictionary objectForKey:indexPath];
                [cell setHighlighted:YES animated:YES];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        {
            NSIndexPath * indexPath = [self indexPathForItemAtPoint:[self.tapGestureRecognizer locationInView:self]];
            if (![self.indexPathsForSelectedItems containsObject:indexPath])
            {
                RICollectionViewCell * cell = [self.visibleCellsDictionary objectForKey:indexPath];
                [cell setHighlighted:NO animated:YES];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            NSIndexPath * indexPath = [self indexPathForItemAtPoint:[self.tapGestureRecognizer locationInView:self]];
            if ([self.indexPathsForSelectedItems containsObject:indexPath])
            {
                if (self.allowsMultipleSelection)
                {
                    [self deselectItemAtIndexPath:indexPath animated:YES];
                }
            }
            else
            {
                [self selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionBottom];
            }
            break;
        }
            
        default:
        {
            break;
        }
    }
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition
{
    NSAssert(indexPath, @"Index path cannot be nil");
    if ([self.indexPathsForSelectedItems containsObject:indexPath]) return;
    
    if (self.allowsMultipleSelection)
    {
        RICollectionViewCell * cell = [self.visibleCellsDictionary objectForKey:indexPath];
        [cell setSelected:YES animated:animated];
     
        NSMutableArray * indexPaths = [NSMutableArray arrayWithArray:self.indexPathsForSelectedItems];
        [indexPaths addObject:indexPath];
        self.indexPathsForSelectedItems = indexPaths;
    }
    else
    {
        NSIndexPath * currentSelectedIndexPath = [self.indexPathsForSelectedItems lastObject];
        if (currentSelectedIndexPath)
        {
            RICollectionViewCell * cell = [self.visibleCellsDictionary objectForKey:currentSelectedIndexPath];
            [cell setSelected:NO animated:animated];
        }
        
        RICollectionViewCell * cell = [self.visibleCellsDictionary objectForKey:indexPath];
        [cell setSelected:YES animated:animated];
        
        self.indexPathsForSelectedItems = [NSArray arrayWithObject:indexPath];
    }
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    NSAssert(indexPath, @"Index path cannot be nil");
    if (![self.indexPathsForSelectedItems containsObject:indexPath]) return;
    
    NSMutableArray * indexPaths = [NSMutableArray arrayWithArray:self.indexPathsForSelectedItems];
    [indexPaths removeObject:indexPath];
    
    RICollectionViewCell * cell = [self.visibleCellsDictionary objectForKey:indexPath];
    [cell setSelected:NO animated:animated];
    
    self.indexPathsForSelectedItems = [indexPaths count] > 0 ? indexPaths : nil;
}

#pragma mark - Reloading

- (void)_computeContentSize {
    CGRect lastSectionFrame;
    [(NSValue *)[self.sectionsFrames lastObject] getValue:&lastSectionFrame];
    CGSize contentSize = CGSizeZero;
    contentSize.width = CGRectGetMaxX(lastSectionFrame);
    contentSize.height = CGRectGetMaxY(lastSectionFrame);
    self.contentSize = contentSize;
}

- (void)_computeSectionFrame:(NSInteger)section {
    CGRect sectionFrame = CGRectZero;
    if (section > 0)
    {
        // Set current section frame.origin from previous section frame
        CGRect previousSectionFrame;
        NSValue * value = [self.sectionsFrames objectAtIndex:section - 1];
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
    
    CGSize boundsSize = self.bounds.size;
    NSArray * itemsFrames = self.itemsFrames[section];
    // Get section frame size from last item frame in section
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
    
    self.sectionsFrames[section] = [NSValue value:&sectionFrame withObjCType:@encode(CGRect)];
}

- (void)_reloadSection:(NSInteger)section
{
	CGSize boundsSize = self.bounds.size;
	int itemsInRow = 0;
	
	switch (self.scrollDirection)
    {
		case RICollectionViewScrollDirectionVertical:
        {
			itemsInRow = boundsSize.width / self.itemSize.width;
			break;
		}
		case RICollectionViewScrollDirectionHorizontal:
        {
			itemsInRow = boundsSize.height / self.itemSize.height;
			break;
		}
	}
    
	// Compute items frames in section coordinate system
	NSInteger numberOfItems = [self.dataSource collectionView:self numberOfItemsInSection:section];
	NSMutableArray * itemsFrames = [NSMutableArray arrayWithCapacity:numberOfItems];
	CGPoint origin = CGPointZero;
	for (unsigned item = 0; item < numberOfItems; ++item)
    {
        int row = item / itemsInRow;
        int col = item % itemsInRow;
		switch (self.scrollDirection)
        {
			case RICollectionViewScrollDirectionVertical:
            {
				origin.x = col * self.itemSize.width;
				origin.y = row * self.itemSize.height;
				break;
			}
			case RICollectionViewScrollDirectionHorizontal:
            {
				origin.x = row * self.itemSize.width;
				origin.y = col * self.itemSize.height;
				break;
			}
		}
		
		CGRect itemFrame = {origin, self.itemSize};
		[itemsFrames addObject:[NSValue value:&itemFrame withObjCType:@encode(CGRect)]];
	}
    
    self.itemsFrames[section] = itemsFrames;
    
    for (unsigned nextSection = section; nextSection < [self.sectionsFrames count]; ++nextSection) {
        [self _computeSectionFrame:nextSection];
    }
}

- (void)reloadData {
	[self.sectionsFrames removeAllObjects];
	[self.itemsFrames removeAllObjects];
	
	NSInteger numberOfSections = 1;
	if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)])
    {
		numberOfSections = [self.dataSource numberOfSectionsInCollectionView:self];
	}
	
	for (unsigned section = 0; section < numberOfSections; ++section)
    {
		[self.sectionsFrames addObject:[NSMutableArray array]];
		[self.itemsFrames addObject:[NSMutableArray array]];
		
		[self _reloadSection:section];
	}
    
    [self _computeContentSize];
    [self _computeIndexPathsForVisibleItems];
    [self _layoutVisibleCells];
}

- (void)reloadSections:(NSIndexSet *)sections {
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self _reloadSection:idx];
    }];
    
    [self _computeContentSize];
    [self _layout];
}

#pragma mark - Dynamic modification cells

- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths {
    for (NSIndexPath * indexPath in indexPaths) {
        if (![self.indexPathsForVisibleItems containsObject:indexPath]) {
            continue;
        }
        
        RICollectionViewCell * cell = [self.visibleCellsDictionary objectForKey:indexPath];
        [cell removeFromSuperview];
        [self _reuseCell:cell];
        [self.visibleCellsDictionary removeObjectForKey:indexPath];
        
        cell = [self.dataSource collectionView:self cellForItemAtIndexPath:indexPath];
        cell.frame = [self _frameForCellAtIndexPath:indexPath];
        [self insertSubview:cell atIndex:0];
        [self.visibleCellsDictionary setObject:cell forKey:indexPath];
    }
}

#pragma mark - Getting cells

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths {
    
}

- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths {
    
}

- (RICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RICollectionViewCell * cell = [self.visibleCellsDictionary objectForKey:indexPath];
    if (!cell) {
        cell = [self.dataSource collectionView:self cellForItemAtIndexPath:indexPath];
    }
    return cell;
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    
}

#pragma mark - Computing visible items

- (void)_computeIndexPathsForVisibleItems
{
    NSMutableArray * indexPathForVisibleItems = [NSMutableArray array];
    // Find first visible section frame
    for (unsigned section = 0; section < [self.sectionsFrames count]; ++section)
    {
        CGRect sectionFrame;
        [(NSValue *)self.sectionsFrames[section] getValue:&sectionFrame];
        if (CGRectIntersectsRect(self.bounds, sectionFrame))
        {
            // Find all visible items frames
            NSArray * frames = self.itemsFrames[section];
            for (unsigned item = 0; item < [frames count]; ++item)
            {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:item inSection:section];
                CGRect itemFrame = [self _frameForCellAtIndexPath:indexPath];
                if (CGRectIntersectsRect(self.bounds, itemFrame))
                {
                    [indexPathForVisibleItems addObject:indexPath];
                }
            }
        }
    }
    self.indexPathsForVisibleItems = indexPathForVisibleItems;
}

- (CGRect)_frameForCellAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect cellFrame;
    [(NSValue *)self.itemsFrames[indexPath.section][indexPath.row] getValue:&cellFrame];
    CGRect sectionFrame;
    [(NSValue *)self.sectionsFrames[indexPath.section] getValue:&sectionFrame];
    cellFrame.origin.x += sectionFrame.origin.x;
    cellFrame.origin.y += sectionFrame.origin.y;
    return cellFrame;
}

- (void)_layoutVisibleCells
{
    for (NSIndexPath * indexPath in [self.visibleCellsDictionary allKeys]) {
        if (![self.indexPathsForVisibleItems containsObject:indexPath]) {
            RICollectionViewCell * cell = [self.visibleCellsDictionary objectForKey:indexPath];
            [self _reuseCell:cell];
            [cell removeFromSuperview];
            [self.visibleCellsDictionary removeObjectForKey:indexPath];
        }
    }
    
    for (NSIndexPath * indexPath in self.indexPathsForVisibleItems)
    {
        RICollectionViewCell * cell = [self.visibleCellsDictionary objectForKey:indexPath];
        if (!cell) {
            cell = [self.dataSource collectionView:self cellForItemAtIndexPath:indexPath];
            if ([self.indexPathsForSelectedItems containsObject:indexPath])
            {
                [cell setSelected:YES animated:NO];
            }
        }
        
        cell.frame = [self _frameForCellAtIndexPath:indexPath];
        [self insertSubview:cell atIndex:0];
        [self.visibleCellsDictionary setObject:cell forKey:indexPath];
    }
}

- (void)_layout {
    [self _computeIndexPathsForVisibleItems];
    [self _layoutVisibleCells];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self) {
        if ([keyPath isEqualToString:@"bounds"]) {
            [self _layout];
        }
    }
}

@end
