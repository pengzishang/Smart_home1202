//
//  CustomStatusBar.m
//  Smart_home
//
//  Created by 彭子上 on 2017/6/2.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import "CustomStatusBar.h"

@implementation CustomStatusBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = [UIApplication sharedApplication].statusBarFrame;
        self.backgroundColor = [UIColor redColor];
        
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.alpha = 0.2;
    }
    return self;
}


-(void)showBar
{
    self.hidden = NO;
    self.alpha = 0.8;
}


-(void)hideBar
{
    self.hidden = YES;
}


@end
