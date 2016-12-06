//
//  LockAddController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/8/23.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface LockAddController : UITableViewController

@property (nonatomic,strong)RoomInfo *currentRoomInfo;
@property(nonatomic,strong)NSMutableArray <__kindof DeviceInfo *>*devicesOfRoom;
@property (nonatomic,strong)RoomInfo *roomInfo;

@end
