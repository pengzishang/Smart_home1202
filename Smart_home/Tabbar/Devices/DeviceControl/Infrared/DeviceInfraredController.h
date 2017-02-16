//
//  DeviceInfraredController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/8/18.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceInfraredController : UIViewController

@property(nonatomic, strong) RoomInfo *roomInfo;
@property(nonatomic, strong) NSMutableArray <__kindof DeviceInfo *> *devices;
@property(nonatomic, strong) DeviceInfo *deviceForAdding;
@property(nonatomic, strong) DeviceInfo *deviceForChanging;
@property(nonatomic, strong) DeviceInfo *deviceForDelete;

@end
