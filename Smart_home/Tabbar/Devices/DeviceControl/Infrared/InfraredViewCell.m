//
//  InfraredViewCell.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/18.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "InfraredViewCell.h"

@implementation InfraredViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setInfoWithDeviceInfo:(DeviceInfo *)deviceInfo
{
    NSArray *itemImage=@[@"add_air",@"add_tv",@"icon_dvd1",@"add_amp",@"icon_digitalbox"];
    self.iconImage.image=[UIImage imageNamed:itemImage[deviceInfo.deviceType.integerValue-100]];
    NSArray *deviceTitle=@[@"空调:",@"电视:",@"DVD:",@"功放机:",@"机顶盒:"];
    self.deviceTypeLab.text=deviceTitle[deviceInfo.deviceType.integerValue-100];
    self.infraredID.text=deviceInfo.deviceInfraredID;
    self.deviceName.text=deviceInfo.deviceCustomName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
