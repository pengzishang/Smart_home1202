//
//  LockController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/8/22.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LockController : UITableViewController

@property(nonatomic, strong) DeviceInfo *deviceForAdding;
@property(nonatomic, strong) NSMutableArray *devices;
@property(nonatomic, strong) RoomInfo *roomInfo;

@end
