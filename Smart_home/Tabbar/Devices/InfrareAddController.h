//
//  InfrareAddController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/8/5.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfrareAddController : UIViewController

@property(nonatomic, strong) NSMutableArray <__kindof DeviceInfo *> *devices;
@property(nonatomic, strong) RoomInfo *roomInfo;

@end
