//
//  DevicesController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/6/30.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceInfo;

@protocol DeviceDelegate <NSObject>

- (void)didClickLeftDrawer;

- (void)didClickSceneIcon:(RoomInfo *)roomInfo;

@end

@interface DevicesController : UITableViewController

@property(nonatomic, strong) RoomInfo *currentRoom;

@property(nonatomic, strong) id <DeviceDelegate> delegate;

- (void)setCommonRoom;

@end
