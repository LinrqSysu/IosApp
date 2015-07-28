//
//  ImageData.m
//  
//
//  Created by samuel on 15/7/27.
//
//

#import "ImageData.h"
#import <UIKit/UIKit.h>

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

@end
