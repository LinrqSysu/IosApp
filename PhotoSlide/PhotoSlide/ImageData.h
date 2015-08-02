//
//  ImageData.h
//  
//
//  Created by samuel on 15/7/27.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NotifyProtocol.h"

@interface ImageData : NSObject

@property (strong, atomic) NSMutableArray* imageUrls;
@property (strong, atomic) NSMutableArray *imageHeights;
@property (strong, nonatomic) NSMutableArray *notifyDelegates;

+ (instancetype) sharedImageData;

- (UIImageView*) imageAtIndex: (NSInteger)index CellSize:(CGRect) bounds;
- (void) saveFileAndNotify: (NSString*) savePath;
- (void) subscribe:(id)observer;
- (CGFloat) GetImageScaleHeight: (CGFloat)scaleWidth;
@end
