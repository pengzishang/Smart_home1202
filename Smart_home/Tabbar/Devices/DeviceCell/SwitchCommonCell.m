//
//  SwitchCommonCell.m
//  Smart_home
//
//  Created by 彭子上 on 2016/7/4.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "SwitchCommonCell.h"

@implementation SwitchCommonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(void)setDeviceName:(NSString *)deviceName
{
    UILabel *deviceNameLab=[self viewWithTag:201];
    deviceNameLab.text=[NSString stringWithFormat:@"设备名称:%@",deviceName];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
