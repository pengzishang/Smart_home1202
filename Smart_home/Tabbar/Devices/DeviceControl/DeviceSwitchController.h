//
//  DeviceSwitchController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/8/15.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceSwitchController : UIViewController

@property(nonatomic, strong) RoomInfo *roomInfo;//本房间信息
@property(nonatomic, strong) NSMutableArray <__kindof DeviceInfo *> *devices;//全部的开关
@property(nonatomic, strong) DeviceInfo *deviceForAdding;
@property(nonatomic, strong) DeviceInfo *deviceForChanging;
@property(nonatomic, strong) DeviceInfo *deviceForDelete;
@end
