//
//  CommonInfraredController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/9/9.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "CommonInfraredController.h"
#import "TTSUtility.h"

@interface CommonInfraredController ()

@end

@implementation CommonInfraredController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(IBAction)pressBtn:(UIButton *)sender
{
    NSLogMethodArgs(@"....%@",self.deviceInfo);
    NSString *btnString=[@(sender.tag-100).stringValue fullWithLengthCount:3];
    NSString *commandString=[[_deviceInfo.deviceInfaredCode stringByAppendingString:btnString]fullWithLengthCountBehide:27];
    [TTSUtility localDeviceControl:_deviceInfo.deviceInfraredID commandStr:commandString retryTimes:0 conditionReturn:^(id stateData) {
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
