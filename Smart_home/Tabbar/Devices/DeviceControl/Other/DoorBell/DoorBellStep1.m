//
//  DoorBellStep1.m
//  Smart_home
//
//  Created by 彭子上 on 2016/10/17.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "DoorBellStep1.h"
#import "DoorBellStep2.h"
#import "JFGSDK/JFGSDKToolMethods.h"

@interface DoorBellStep1 () <UIApplicationDelegate>

//1.增加远程服务器
//2.修复一些远程服务器问题
//3.修改编辑开关名称问题
//4.修改锁名字问题
@end

@implementation DoorBellStep1

- (void)viewDidLoad {
    [super viewDidLoad];
    _wifiSSID = [JFGSDKToolMethods currentWifiName];
    if ([_wifiSSID hasPrefix:@"DOG-ML"]) {
        _nextStep.enabled = YES;
        [_nextStep setTitle:@"下一步" forState:UIControlStateNormal];
    } else {
        _lastWifiSSID = _wifiSSID;
        if (_wifiSSID.length < 1) {
            [_nextStep setTitle:@"移动网络" forState:UIControlStateNormal];
        } else {
            [_nextStep setTitle:[NSString stringWithFormat:@"当前:%@", _wifiSSID] forState:UIControlStateNormal];
        }

    }

    // Do any additional setup after loading the view.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DoorBellStep2 *target = segue.destinationViewController;
    if (![_lastWifiSSID hasPrefix:@"DOG-ML"]) {
        target.wifiSSID = _lastWifiSSID;
    } else {
        target.wifiSSID = @"请设置一个可用WiFi";
    }

}


@end
