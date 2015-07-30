//
//  PhotoFallLayout.m
//  PhotoSlide
//
//  Created by samuel on 15/7/27.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import "Common.h"
#import "ImageData.h"
#import "PhotoFallLayout.h"

@implementation PhotoFallLayout
@synthesize inset;
@synthesize itermWidth;
@synthesize itermSpace;

- (void)prepareLayout
{
    [super prepareLayout];
    
    // 初始化参数
    inset = GLOBAL_INSET;
    itermSpace = GLOBAL_ITEM_SPACE;
    itermWidth = ([Common globalWidth] - inset.left - inset.right - 2 * itermSpace) / 3; // cell宽度
    
    if (!self.cellY)
    {
        self.cellY = [NSMutableArray array];
    }
    else
    {
        [self.cellY removeAllObjects];
    }
    
    NSLog(@"begin prepareLayout, imageHeights.count=%lu", [[ImageData sharedImageData].imageHeights count]);
    self.maxHeight = self.collectionView.frame.size.height;
    //NSUInteger count = [[ImageData sharedImageData].imageHeights count];
    for ( NSUInteger i = 0; i < _currentCellCount; i++)
    {
        if (i < 3) [self.cellY addObject:[NSNumber numberWithFloat:self.inset.top]];
        else
        {
            NSNumber *num = [NSNumber numberWithFloat:self.itermSpace
                             + ((NSNumber *)self.cellY[i - 3]).floatValue
                             + [[[ImageData sharedImageData].imageHeights objectAtIndex:i-3] integerValue]];
            
            [self.cellY addObject:num];
            self.maxHeight = MAX(self.maxHeight, [num floatValue] + [[[ImageData sharedImageData].imageHeights objectAtIndex:i] floatValue]);
            
            NSLog(@"current i=%lu num=%ld maxHeight=%f", (unsigned long)i, (long)[num integerValue], self.maxHeight);
        }
    }
}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = CGSizeMake(self.collectionView.frame.size.width, self.maxHeight + inset.bottom + inset.top);
    NSLog(@"current collectionViewContentSize.height=%f", contentSize.height);
    return contentSize;
}
                             
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSLog(@"ForElementsInRect, imageHeights.count=%lu, cellY.count=%lu, thread=%@", [[ImageData sharedImageData].imageHeights count], (unsigned long)[self.cellY count], [NSThread currentThread]);
     NSMutableArray *attributes = [NSMutableArray array];
     for (int i = 0; i < self.cellY.count; i++) {
         NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
         [attributes addObject:[self layoutAttributesForItemAtIndexPath:index]];
     }
     return attributes;
 }
                             
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"ForItemAtIndexPath, indexPath.item=%lu, imageHeights.count=%lu, cellY.count=%lu", (unsigned long)indexPath.item, [[ImageData sharedImageData].imageHeights count], [self.cellY count]);
    int i = (int)indexPath.item;
    if( i >= [self.cellY count] || i >= [[ImageData sharedImageData].imageHeights count])
    {
        NSLog(@"invalid index, i=%d", i);
        return nil;
    }
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(self.inset.left + (self.itermSpace + self.itermWidth) * (i % 3),
                                   ((NSNumber *)self.cellY[i]).floatValue + [Common globalStatusBarHeight],
                                   self.itermWidth,
                                  [[[ImageData sharedImageData].imageHeights objectAtIndex:i] floatValue]);
    NSLog(@"At Index Path_called: index=%d, height=%f", i, attributes.frame.size.height);
    return attributes;
 }
 

@end
