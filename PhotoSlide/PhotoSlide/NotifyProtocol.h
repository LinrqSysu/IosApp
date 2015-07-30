//
//  NotifyProtocol.h
//  PhotoSlide
//
//  Created by samuel on 15/7/29.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadNotify <NSObject>
@optional

-(void) notifyDownloadFinished:(NSError *)error;

@end
