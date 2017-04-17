//
//  UIButton+touchLimit.h
//  BinMarker
//
//  Created by 彭子上 on 2017/4/1.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>
#define defaultInterval .7// 默认间隔时间
@interface UIButton (touchLimit)
/**
 *  设置点击时间间隔
 */
@property (nonatomic, assign) NSTimeInterval timeInterVal;
@end
