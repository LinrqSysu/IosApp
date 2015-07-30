//
//  ImageData.h
//  
//
//  Created by samuel on 15/7/27.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageData : NSObject

@property (nonatomic) NSInteger count;

+ (instancetype) sharedImageData;

@end
