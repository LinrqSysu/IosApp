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
#import "PhotoFallViewController.h"

@implementation PhotoFallLayout
@synthesize inset;
@synthesize itemWidth;
@synthesize itemSpace;



#pragma layout
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
    
    self.maxHeight = self.collectionView.frame.size.height;
    
    PhotoFallViewController *controller = self.collectionView.delegate;
    if( controller.searchFlag && controller.searchBar.text != nil)
    {
        _useSearch = YES;
    }
    else
    {
        _useSearch = NO;
    }
    
    NSInteger count = 0;
    if( _useSearch )
    {
        count = [[ImageData sharedImageData] getImageCountMatchSearch: controller.searchBar.text];
    }
    else
    {
        count = [[ImageData sharedImageData] getImageCount];
    }
    
    NSLog(@"begin_prepareLayout, _useSearch=%d count =%ld imageUrls.count=%lu thread=%@", _useSearch, count,  [[ImageData sharedImageData].imageUrls count],[NSThread currentThread]);
   
    for ( NSUInteger i = 0; i < count; i++)
    {
        //根据当前的cell index，找到对应的image index
        NSUInteger currentRowImageIndex = [[ImageData sharedImageData] getImageIndex: i UseSearch:_useSearch];
        NSUInteger lastRowImageIndex = [[ImageData sharedImageData] getImageIndex: i-3 UseSearch:_useSearch];
        
        //保存每个图片的y坐标
        if (i < 3) [self.cellY addObject:[NSNumber numberWithFloat:(self.inset.top + 30 + SEARCH_BAR_HEIGHT)]];
        else
        {
            NSNumber *num = [NSNumber numberWithFloat:self.itemSpace
                             + ((NSNumber *)self.cellY[i - 3]).floatValue
                             + [[[ImageData sharedImageData].imageHeights objectAtIndex:lastRowImageIndex] integerValue]];
            
            [self.cellY addObject:num];
            self.maxHeight = MAX(self.maxHeight, [num floatValue] + [[[ImageData sharedImageData].imageHeights objectAtIndex:currentRowImageIndex] floatValue]);
            
            NSLog(@"current i=%lu currentRowImageIndex=%lu lastRowImageIndex=%lu num=%ld maxHeight=%f", (unsigned long)i, currentRowImageIndex, lastRowImageIndex, (long)[num integerValue], self.maxHeight);
        }
        
        //获得最后三个cell中，heigth最小的一个 FIXME
        _minHeight = _maxHeight;
    }
    
    NSLog(@"end prepareLayout, cellY.count=%lu", [_cellY count]);
}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = CGSizeMake(self.collectionView.frame.size.width, self.maxHeight + inset.bottom + inset.top);
    NSLog(@"current collectionViewContentSize.height=%f", contentSize.height);
    
    //FIXME 可在这里判断，若minHeight比较小，可以触发更新
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
    //NSLog(@"ForItemAtIndexPath, indexPath.item=%lu, imageHeights.count=%lu, cellY.count=%lu", (unsigned long)indexPath.item, [[ImageData sharedImageData].imageHeights count], [self.cellY count]);
    int i = (int)indexPath.item;
    if( i >= [self.cellY count] || i >= [[ImageData sharedImageData].imageHeights count])
    {
        NSLog(@"invalid index, i=%d", i);
        return nil;
    }
    
    NSUInteger imageIndex = [[ImageData sharedImageData] getImageIndex:i UseSearch:_useSearch];
    NSLog(@"layoutAttributesForItemAtIndexPath _useSearch=%d cellindex=%d imageIndex=%lu imageHeight.cout=%lu", _useSearch, i, imageIndex, [[ImageData sharedImageData].imageHeights count]);
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(self.inset.left + (self.itemSpace + self.itemWidth) * (i % 3),
                                   ((NSNumber *)self.cellY[i]).floatValue + [Common globalStatusBarHeight],
                                   self.itemWidth,
                                  [[[ImageData sharedImageData].imageHeights objectAtIndex:imageIndex] floatValue]);
    NSLog(@"At Index Path_called: index=%d, height=%f", i, attributes.frame.size.height);
    return attributes;
 }


@end
