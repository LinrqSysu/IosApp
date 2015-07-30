//
//  ImageData.m
//  
//
//  Created by samuel on 15/7/27.
//
//

#import "Common.h"
#import "ImageData.h"
#import <UIKit/UIKit.h>

@interface ImageData()
@end

@implementation ImageData

+ (instancetype) sharedImageData
{
    static ImageData *imageData;
    static dispatch_once_t once;
    
    dispatch_once( &once, ^{
        imageData = [[self alloc] init];
    });
    
    return imageData;
}

- (UIImageView*) imageAtIndex: (NSInteger)index CellSize:(CGRect) bounds
{
    NSString* url = self.imageUrls[index];
    
    UIImage *image = [UIImage imageNamed:url];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:bounds];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.image = image;
    imageView.layer.backgroundColor = [UIColor grayColor].CGColor;
    imageView.layer.borderWidth = 0.5;
    
    return imageView;
}

- (void) saveFile: (NSString*) savePath
{
    //保存url到数组中
    if (self.imageUrls)
    {
        [self.imageUrls addObject:savePath];
    } else
    {
        self.imageUrls = [[NSMutableArray alloc] initWithObjects:savePath, nil];
    }
    
    UIImage *image = [UIImage imageNamed:savePath];
    if (!image) {
        NSLog(@"load image file failed, savePath=%@", savePath);
        return;
    }
    
    //按比例得到高度，并保存尺寸到数组中
    
    UIEdgeInsets inset = GLOBAL_INSET;
    int itermSpace = GLOBAL_ITEM_SPACE;
    int itermWidth = ([Common globalWidth] - inset.left - inset.right - 2 * itermSpace) / 3; // cell宽度
    NSNumber *zoomOutHeight = [NSNumber numberWithFloat:(image.size.height / image.size.width ) * itermWidth + arc4random_uniform(80)];
    if (self.imageHeights)
    {
        [self.imageHeights addObject:zoomOutHeight];
    } else
    {
        self.imageHeights = [[NSMutableArray alloc] initWithObjects:zoomOutHeight, nil];
    }
    
    //通知layout更新
    NSError* error;
    for (id<DownloadNotify> observer in self.notifyDelegates) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(id<DownloadNotify>)observer notifyDownloadFinished:error];
        });
    }
    NSLog(@"push data called: zoomOutHeight=%@ imageHeights.count=%d now %d images, notify %d views at thread %@",
          zoomOutHeight,
          (int)[self.imageHeights count],
          (int)[self.imageUrls count],
          (int)self.notifyDelegates.count,
          [NSThread currentThread]);
    
    return;
}

- (void)subscribe:(id)observer {
    if (self.notifyDelegates) {
        [self.notifyDelegates addObject:observer];
    } else {
        self.notifyDelegates = [[NSMutableArray alloc] initWithObjects:observer, nil];
    }
    NSLog(@"subscriber count=%d", (int)self.notifyDelegates.count);
}

@end
