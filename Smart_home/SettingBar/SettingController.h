//
//  SettingController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/8/12.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingBarDelegate <NSObject>

-(void)didClickRemoteSwitch:(UISwitch *)remoteSwitch;

-(void)didClickSettingTableItem:(NSUInteger)index;

@end

@interface SettingController : UIViewController

@property(nonatomic,assign)id<SettingBarDelegate>delegate;

@end
