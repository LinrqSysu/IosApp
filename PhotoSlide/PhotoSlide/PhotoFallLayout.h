//
//  PhotoFallLayout.h
//  PhotoSlide
//
//  Created by samuel on 15/7/27.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoFallLayout : UICollectionViewLayout

@property (nonatomic) NSInteger cellCount;
@property (nonatomic) UIEdgeInsets inset;
@property (nonatomic) CGFloat itermWidth;
@property (nonatomic) CGFloat itermSpace;
@property (nonatomic) CGFloat maxHeight;
@property (strong, atomic) NSMutableArray *cellY;


@end
