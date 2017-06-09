//
//  CustomStatusBar.h
//  Smart_home
//
//  Created by 彭子上 on 2017/6/2.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomStatusBar : UIWindow

@property (nonatomic,strong) UILabel * messageLab;

-(instancetype)init;
-(void)showBar;
-(void)hideBar;

@end
