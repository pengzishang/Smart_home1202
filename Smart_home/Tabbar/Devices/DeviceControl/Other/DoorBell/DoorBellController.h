//
//  DoorBellController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/10/11.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JFGSDK/JFGSDK.h>

@interface DoorBellController : UIViewController

@property(nonatomic, strong) NSString *editName;
@property(nonatomic, strong) JFGSDKDevice *editDevice;

@end
