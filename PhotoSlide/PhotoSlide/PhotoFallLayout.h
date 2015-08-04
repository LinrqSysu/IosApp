//
//  PhotoFallLayout.h
//  PhotoSlide
//
//  Created by samuel on 15/7/27.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoFallLayout : UICollectionViewLayout

@property (nonatomic) BOOL useSearch;
@property (nonatomic) UIEdgeInsets inset;
@property (nonatomic) CGFloat itemWidth;
@property (nonatomic) CGFloat itemSpace;
@property (nonatomic) CGFloat maxHeight;
@property (nonatomic) CGFloat minHeight;
@property (strong, atomic) NSMutableArray *cellY;


@end
