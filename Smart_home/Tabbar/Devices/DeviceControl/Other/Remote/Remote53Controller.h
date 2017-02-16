//
//  Remote53Controller.h
//  Smart_home
//
//  Created by 彭子上 on 2016/9/22.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Remote53Controller : UIViewController

@property(nonatomic, strong) NSString *remoteDeviceID;
@property(nonatomic, strong) DeviceInfo *currentDevice;

@end
