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
@synthesize itemWidth;
@synthesize itemSpace;

- (void)prepareLayout
{
    [super prepareLayout];
    
    // 初始化参数
    inset = GLOBAL_INSET;
    itemSpace = GLOBAL_ITEM_SPACE;
    itemWidth = ([Common globalWidth] - inset.left - inset.right - 2 * itemSpace) / 3; // cell宽度
    
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
    
    //必须使用上次保存的currentCellCount，不然可能会crash（dataSource和layout中返回的个数不一致)
    for ( NSUInteger i = 0; i < _currentCellCount; i++)
    {
        //保存每个图片的y坐标
        if (i < 3) [self.cellY addObject:[NSNumber numberWithFloat:(self.inset.top + 30)]];
        else
        {
            NSNumber *num = [NSNumber numberWithFloat:self.itemSpace
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
    
    /*
    NSIndexPath *headIndex = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:headIndex];
    [attributes addObject:headerAttributes];
     */
    
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
    attributes.frame = CGRectMake(self.inset.left + (self.itemSpace + self.itemWidth) * (i % 3),
                                   ((NSNumber *)self.cellY[i]).floatValue + [Common globalStatusBarHeight],
                                   self.itemWidth,
                                  [[[ImageData sharedImageData].imageHeights objectAtIndex:i] floatValue]);
    NSLog(@"At Index Path_called: index=%d, height=%f", i, attributes.frame.size.height);
    return attributes;
 }

/*
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                               atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"ForSupplementaryView, indexPath.item=%lu, kind=%@", (unsigned long)indexPath.item, kind);
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    attributes.frame = CGRectMake(0, 4 + [Common globalStatusBarHeight], [Common globalWidth], 30);
    
    return attributes;
}
*/


@end
