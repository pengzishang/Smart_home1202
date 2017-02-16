//
//  DoorBellStep1.h
//  Smart_home
//
//  Created by 彭子上 on 2016/10/17.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoorBellStep1 : UIViewController

@property(strong, nonatomic) NSString *wifiSSID;
@property(strong, nonatomic) NSString *lastWifiSSID;
@property(weak, nonatomic) IBOutlet UIButton *nextStep;
@end
