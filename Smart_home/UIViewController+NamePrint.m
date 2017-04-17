//
//  UIViewController+NamePrint.m
//  BinMarker
//
//  Created by 彭子上 on 2017/4/1.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import "UIViewController+NamePrint.h"
#import <objc/runtime.h>
@implementation UIViewController (NamePrint)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method viewDidLoad=class_getInstanceMethod(self, @selector(viewDidLoad));
        Method viewDidLoadWithPrintName=class_getInstanceMethod(self, @selector(viewDidLoadWithPrintName));
        method_exchangeImplementations(viewDidLoad, viewDidLoadWithPrintName);
    });
}


-(void)viewDidLoadWithPrintName
{
    [self viewDidLoadWithPrintName];
    NSLog(@"视图:%@ 被载入",self);
}

@end
