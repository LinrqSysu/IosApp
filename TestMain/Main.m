//
//  Main.m
//  TestMain
//
//  Created by samuel on 15/8/3.
//
//

#import <Foundation/Foundation.h>

int main(int argc, char * argv[])
{
    int a = 10,b=20;
    
    typedef double (^TestBlock)(void);
    
    TestBlock multiply = ^(void){ return a*b; };
    
    NSLog(@"%f", multiply());
    
    a=20;
    NSLog(@"%f", multiply());
    
    return 0;
}