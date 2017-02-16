//
//  AddDevicesController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/7/8.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceInfo;

@interface AddDevicesController : UIViewController

//@property (nonatomic,strong)RoomInfo *currentRoomInfo;
@property(strong, nonatomic) NSArray <__kindof DeviceInfo *> *deviceOfRoom;

@property(strong, nonatomic) RoomInfo *roomInfo;

@end
