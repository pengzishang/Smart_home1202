//
//  InfraredViewCell.h
//  Smart_home
//
//  Created by 彭子上 on 2016/8/18.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfraredViewCell : UITableViewCell
@property(weak, nonatomic) IBOutlet UILabel *deviceName;
@property(weak, nonatomic) IBOutlet UIImageView *iconImage;
@property(weak, nonatomic) IBOutlet UILabel *deviceTypeLab;
@property(weak, nonatomic) IBOutlet UILabel *infraredID;

- (void)setInfoWithDeviceInfo:(DeviceInfo *)deviceInfo;

@end
