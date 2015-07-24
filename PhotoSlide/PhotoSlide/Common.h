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

@interface Common : NSObject

+ ( CGFloat ) globalHeight;

+ ( CGFloat ) globalWidth;

+ ( CGFloat ) globalStatusBarHeight;

+ (UIColor *) globalBackgroundColor;
@end
