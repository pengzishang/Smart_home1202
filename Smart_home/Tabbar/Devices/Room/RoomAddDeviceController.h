//
//  RoomAddDeviceController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/8/30.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface RoomAddDeviceController : UITableViewController

@property (nonatomic,strong)RoomInfo *roomInfo;
@property (nonatomic,strong)NSMutableArray <__kindof DeviceInfo *>*devicesOfRoom;
@property (nonatomic,strong)NSMutableArray *devicesOfAll;
@property (nonatomic,strong)NSString *enterId;//进入此Control的视图ID

@end
