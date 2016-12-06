//
//  SwitchOneCell.m
//  Smart_home
//
//  Created by 彭子上 on 2016/7/2.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "SwitchOneCell.h"

@implementation SwitchOneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.switch_one_btn.hidden=NO;
    // Configure the view for the selected state
}

@end
