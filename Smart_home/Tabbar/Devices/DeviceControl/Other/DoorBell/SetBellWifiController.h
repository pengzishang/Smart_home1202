//
//  SetBellWifiController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/11/8.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <JFGSDK/JFGSDK.h>

@interface SetBellWifiController : UITableViewController

@property(strong, nonatomic) JFGSDKDevice *device;
@property(strong, nonatomic) NSString *ssid;

@end
