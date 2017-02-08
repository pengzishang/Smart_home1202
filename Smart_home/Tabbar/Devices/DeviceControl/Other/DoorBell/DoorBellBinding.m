//
//  DoorBellBinding.m
//  Smart_home
//
//  Created by 彭子上 on 2016/10/18.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "DoorBellBinding.h"
#import <JFGSDK/JFGSDKBindingDevice.h>
@interface DoorBellBinding ()<JFGSDKBindDeviceDelegate>
{
    JFGSDKBindingDevice *bindDevice;
    __weak IBOutlet UIButton *complete;
    __weak IBOutlet UILabel *binding;
}

@property (weak, nonatomic) IBOutlet UIImageView *mainImage;

@end

@implementation DoorBellBinding

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *imgSet=@[[UIImage imageNamed:@"device_bind_0"],[UIImage imageNamed:@"device_bind_1"],[UIImage imageNamed:@"device_bind_2"],[UIImage imageNamed:@"device_bind_3"],[UIImage imageNamed:@"device_bind_4"],[UIImage imageNamed:@"device_bind_5"]];
    
    [self.mainImage setAnimationImages:imgSet];
    [self.mainImage setAnimationRepeatCount:0];
    [self.mainImage setAnimationDuration:5*0.74];
    [self.mainImage startAnimating];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    bindDevice = [[JFGSDKBindingDevice alloc]init];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    bindDevice.delegate = self;
    //借助设备扫描周边wifi
    [bindDevice scanWifi];
    [bindDevice bindDevWithSn:nil ssid:_wifiSSID key:_wifiPWD];
}
//绑定过程及成功回调
-(void)jfgBindDeviceProgressStatus:(JFGSDKBindindProgressStatus)status
{
    if (status == JFGSDKBindindProgressStatusSuccess) {
        NSLog(@"bind-Result:success");
        complete.enabled=YES;
        [self.mainImage stopAnimating];
        [self.mainImage setImage:[UIImage imageNamed:@"device_bind_suc"]];
        binding.text=@"绑定成功,按完成返回";
    }
    else{
        NSLog(@"%zd",status);
    }
}

//绑定失败
-(void)jfgBindDeviceFailed:(JFGSDKBindindProgressStatus)errorType;
{
    NSLog(@"bind-Result:fail:%zd",errorType);
    [self.mainImage stopAnimating];
    [self.mainImage setImage:[UIImage imageNamed:@"device_bind_fail"]];
    complete.enabled=YES;
    binding.text=@"绑定失败,请重试";
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
