//
//  AppDelegate.h
//  PhotoSlide
//
//  Created by samuel on 15/7/24.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *rootController;

@property (strong, nonatomic) NSString *imageDirectory;

@end

