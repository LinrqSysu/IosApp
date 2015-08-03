//
//  PhotoFallViewController.h
//  PhotoSlide
//
//  Created by samuel on 15/7/24.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotifyProtocol.h"

@interface PhotoFallViewController : UICollectionViewController<DownloadNotify,UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) UICollectionView* fallView;
-(void) notifyDownloadFinished:(NSError *)error;
- (instancetype)initWithHeight: (CGFloat)viewHeight Title:(NSString*) title;
@end
