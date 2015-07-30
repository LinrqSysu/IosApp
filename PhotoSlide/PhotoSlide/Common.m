//
//  Common.m
//  PhotoSlide
//
//  Created by samuel on 15/7/24.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import "Common.h"

@implementation Common

+ ( CGFloat ) globalHeight
{
    return [[UIScreen mainScreen] bounds].size.height;
}

+ ( CGFloat ) globalWidth
{
    return [[UIScreen mainScreen] bounds].size.width;
}

+ ( CGFloat ) globalStatusBarHeight
{
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

+ (UIColor *) globalBackgroundColor {
    return [UIColor colorWithRed:200.0/255 green:202.0/255 blue:204.0/255 alpha:1];
}

+ (CGFloat) globalImageWidth{
    return ([[UIScreen mainScreen] bounds].size.width - (IMAGE_COUNT_PER_ROW  * IMAGE_INTERVAL));
}

@end
