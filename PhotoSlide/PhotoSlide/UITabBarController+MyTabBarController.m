//
//  UITabBarController+MyTabBarController.m
//  PhotoSlide
//
//  Created by samuel on 15/7/24.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import "PhotoFallViewController.h"
#import "PhotoWallViewController.h"
#import "Common.h"
#import "UITabBarController+MyTabBarController.h"

@implementation UITabBarController (MyTabBarController)

- (id) initWithHeight: (CGFloat) viewHeight;
{
    self = [self init];
    
    PhotoFallViewController *photoFallController = [[PhotoFallViewController alloc] initWithHeight:viewHeight];
    photoFallController.title = @"瀑布流";
    photoFallController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"瀑布流" image:nil tag:0];
    photoFallController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, TAB_BAR_ITEM_TITLE_OFFSET);
    
    PhotoWallViewController *photoWallController = [[PhotoWallViewController alloc] initWithHeight:viewHeight];
    photoWallController.title = @"照片墙";
    photoWallController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"照片墙" image:nil tag:1];
    photoWallController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, TAB_BAR_ITEM_TITLE_OFFSET);
    
    self.viewControllers = [NSArray arrayWithObjects: photoWallController, photoFallController, nil];
    
    return self;
}

@end
