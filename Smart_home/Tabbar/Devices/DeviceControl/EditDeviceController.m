//
//  EditDeviceController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/17.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "EditDeviceController.h"
#import "DeviceSwitchController.h"
#import "TTSCoreDataManager.h"
#import "TTSUtility.h"
#import "NSString+StringOperation.h"
@interface EditDeviceController ()
@property (weak, nonatomic) IBOutlet UIImageView *switchImage;
@property (weak, nonatomic) IBOutlet UILabel *macID;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *confirm;
@property (weak, nonatomic) IBOutlet UIButton *remoteBtn;



@end

@implementation EditDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *auto_add_image=@[@"auto_add_type00",@"auto_add_type01",@"auto_add_type02",@"auto_add_type03",@"auto_add_type04",@"auto_add_type05"];
    _switchImage.image=[UIImage imageNamed:auto_add_image[self.deviceInfo.deviceType.integerValue]];
    _macID.text=[NSString stringWithFormat:@"设备Mac地址:%@",self.deviceInfo.deviceMacID];
    if (self.deviceInfo.deviceRemoteMac.length==0) {
        [_remoteBtn setTitle:[NSString stringWithFormat:@"设为默认远程控制器:%@",RemoteDefault] forState:UIControlStateNormal];
    }
    else
    {
        [_remoteBtn setTitle:[NSString stringWithFormat:@"远程控制器:%@",self.deviceInfo.deviceRemoteMac] forState:UIControlStateNormal];
    }
    
    
    _nameField.placeholder=[NSString stringWithFormat:@"%@",self.deviceInfo.deviceCustomName];
    // Do any additional setup after loading the view.
}
- (IBAction)deleteDevice:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"edit2MainSwitch" sender:nil];
}
- (IBAction)confirmName:(UIButton *)sender {
    [_nameField endEditing:YES];
    self.deviceInfo.deviceCustomName=_nameField.text;
    [[TTSCoreDataManager getInstance]updateData];
}
- (IBAction)setRemote:(UIButton *)sender {
    if (self.deviceInfo.deviceRemoteMac.length==0) {
        self.deviceInfo.deviceRemoteMac=RemoteDefault;
        [[TTSCoreDataManager getInstance]updateData];
        [_remoteBtn setTitle:[NSString stringWithFormat:@"远程控制器:%@",self.deviceInfo.deviceRemoteMac] forState:UIControlStateNormal];
    }
    [TTSUtility syncRemoteDevice:self.deviceInfo remoteMacID:self.deviceInfo.deviceRemoteMac conditionReturn:^(NSString *statusCode) {
        NSLogMethodArgs(@"%@",statusCode);
    }];
}
- (IBAction)complete:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"edit2MainSwitch" sender:self.deviceInfo];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(DeviceInfo *)sender {
    if ([segue.identifier isEqualToString:@"edit2MainSwitch"]) {
        DeviceSwitchController *target=segue.destinationViewController;
        if (sender) {
            target.deviceForChanging=self.deviceInfo;
        }
        else
        {
            target.deviceForDelete=self.deviceInfo;
        }
    }
}


@end
