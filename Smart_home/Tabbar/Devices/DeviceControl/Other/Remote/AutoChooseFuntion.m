//
//  AutoChooseFuntion.m
//  Smart_home
//
//  Created by 彭子上 on 2016/9/21.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "AutoChooseFuntion.h"
#import "BluetoothManager.h"
#import "Remote53Controller.h"

@interface AutoChooseFuntion ()

@end

@implementation AutoChooseFuntion

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startScan];
    // Do any additional setup after loading the view.
}

- (void)startScan {
    [[BluetoothManager getInstance] scanPeriherals:YES AllowPrefix:nil];
    [BluetoothManager getInstance].detectDevice = ^(NSDictionary *infoDic) {
        if ([infoDic[@"adData"][@"kCBAdvDataLocalName"] hasPrefix:@"Rem-53"]) {
            [[BluetoothManager getInstance] stopScan];
            NSString *deviceName = infoDic[@"adData"][@"kCBAdvDataLocalName"];
            deviceName = [deviceName substringFromIndex:7];
            [self performSegueWithIdentifier:@"remote53" sender:deviceName];
        } else if ([infoDic[@"adData"][@"kCBAdvDataLocalName"] hasPrefix:@"Rem-Da"]) {
            [[BluetoothManager getInstance] stopScan];
            NSString *deviceName = infoDic[@"adData"][@"kCBAdvDataLocalName"];
            deviceName = [deviceName substringFromIndex:7];
            [self performSegueWithIdentifier:@"remoteSwitch" sender:deviceName];
        }
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSString *)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"remote53"]) {
        Remote53Controller *remote = segue.destinationViewController;
        remote.remoteDeviceID = sender;
    } else if ([segue.identifier isEqualToString:@"remotebig"]) {

    } else if ([segue.identifier isEqualToString:@"remoteSwitch"]) {
//        RemoteOneSwitchController *remote=segue.destinationViewController;
//        remote.remoteDeviceID=sender;
    }
}

@end
