//
//  main.m
//  TestMainCmd
//
//  Created by samuel on 15/8/3.
//  Copyright (c) 2015年 samuel. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        static int a = 10,b=20;
        
        typedef int (^TestBlock)(void);
        
        TestBlock multiply = ^(void){ return a*b; };
        
        NSLog(@"%d", multiply());
        
        a=20;
        NSLog(@"%d", multiply());
        
        return 0;
    }
    return 0;
}
