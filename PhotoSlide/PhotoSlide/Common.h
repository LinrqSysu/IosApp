//
//  Common.h
//  PhotoSlide
//
//  Created by samuel on 15/7/24.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

#define TAB_BAR_ITEM_TITLE_OFFSET -15.0
#define IMAGE_INTERVAL 5
#define IMAGE_COUNT_PER_ROW 3
#define FLICKR_FETCH_ID @"fetch_list"
#define FLICKR_FETCH_LIST @"fetch_list"
#define FLICKR_FETCH_IMAGE @"fetch_single_image"
#define GLOBAL_INSET UIEdgeInsetsMake(4, 4, 4, 4)
#define GLOBAL_ITEM_SPACE 5 

@interface Common : NSObject

+ ( CGFloat ) globalHeight;

+ ( CGFloat ) globalWidth;

+ ( CGFloat ) globalStatusBarHeight;

+ (UIColor *) globalBackgroundColor;

+ (CGFloat ) globalImageWidth;

@end
