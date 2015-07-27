//
//  PhotoFallLayout.m
//  PhotoSlide
//
//  Created by samuel on 15/7/27.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import "Common.h"
#import "PhotoFallLayout.h"

@implementation PhotoFallLayout
@synthesize cellCount;
@synthesize inset;
@synthesize itermWidth;

- (void)prepareLayout
{
    [super prepareLayout];
    
    // 初始化参数
    cellCount = [self.collectionView numberOfItemsInSection:0]; // cell个数，直接从collectionView中获得
    inset = 5; // 设置间距
    itermWidth = [Common globalWidth] / 3 - 4 * inset; // cell宽度
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake([Common globalWidth], self.collectionView.frame.size.height + self.inset*2);
}


@end
