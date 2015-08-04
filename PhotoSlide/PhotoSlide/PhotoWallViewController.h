//
//  PhotoWallViewController.h
//  PhotoSlide
//
//  Created by samuel on 15/7/24.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoWallViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, DownloadNotify>
-(void) notifyDownloadFinished:(NSString*)filename Error:(NSError *)error;
-(instancetype)initWithHeight: (CGFloat)photoViewHeight;
@end
