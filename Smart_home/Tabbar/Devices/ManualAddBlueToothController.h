//
//  ManualAddBlueToothController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/7/9.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ManualAddBlueToothController : UITableViewController
@property (strong,nonatomic)NSArray <__kindof DeviceInfo *>*deviceOfRoom;
@property (strong,nonatomic)RoomInfo *roomInfo;


@end
