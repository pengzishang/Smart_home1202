//
//  SceneCellCommon.m
//  Smart_home
//
//  Created by 彭子上 on 2016/9/18.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "SceneCellCommon.h"

@interface SceneCellCommon ()

@property(nonatomic, strong) NSIndexPath *index;

@end

@implementation SceneCellCommon


/**
 返回cell的Btn图片
 
 @param status     状态设定
 @param deviceType 设备类型
 
 @return 图片名数组返回
 */
- (NSArray *)imageReturnWithStatus:(NSUInteger)status deviceType:(NSUInteger)deviceType {
    NSArray *imageReturn = [NSArray array];
    switch (deviceType) {
        case 0:
        case 1: {
            if (status == 0) {
                imageReturn = @[@"light_off_scene"];
            } else if (status == 1) {
                imageReturn = @[@"light_on_scene"];
            }
        }
            break;
        case 2: {
            if (status == 0) {
                imageReturn = @[@"light_off_scene", @"light_off_scene"];
            } else if (status == 1) {
                imageReturn = @[@"light_on_scene", @"light_off_scene"];
            } else if (status == 2) {
                imageReturn = @[@"light_off_scene", @"light_on_scene"];
            } else if (status == 3) {
                imageReturn = @[@"light_on_scene", @"light_on_scene"];
            }
        }
            break;
        case 3: {
            if (status == 0) {
                imageReturn = @[@"light_off_scene", @"light_off_scene", @"light_off_scene"];
            } else if (status == 1) {
                imageReturn = @[@"light_on_scene", @"light_off_scene", @"light_off_scene"];
            } else if (status == 2) {
                imageReturn = @[@"light_off_scene", @"light_on_scene", @"light_off_scene"];
            } else if (status == 3) {
                imageReturn = @[@"light_on_scene", @"light_on_scene", @"light_off_scene"];
            } else if (status == 4) {
                imageReturn = @[@"light_off_scene", @"light_off_scene", @"light_on_scene"];
            } else if (status == 5) {
                imageReturn = @[@"light_on_scene", @"light_off_scene", @"light_on_scene"];
            } else if (status == 6) {
                imageReturn = @[@"light_off_scene", @"light_on_scene", @"light_on_scene"];
            } else if (status == 7) {
                imageReturn = @[@"light_on_scene", @"light_on_scene", @"light_on_scene"];
            }
        }
            break;
        case 4:
        case 5: {
            if (status == 1) {
                imageReturn = @[@"light_on_scene"];
            } else if (status == 2) {
                imageReturn = @[@"light_off_scene"];
            }
        }
            break;
        default:
            imageReturn = nil;
    }
    return imageReturn;
}

- (void)setImageWithStatus:(NSUInteger)deviceStatus deviceType:(NSUInteger)deviceType index:(NSIndexPath *)index {
    self.index = index;
    NSArray *images = [self imageReturnWithStatus:deviceStatus deviceType:deviceType];
    if (images.count == 1) {
        [_btn1 setImage:[UIImage imageNamed:images[0]] forState:UIControlStateNormal];
    } else if (images.count == 2) {
        [_btn1 setImage:[UIImage imageNamed:images[0]] forState:UIControlStateNormal];
        [_btn2 setImage:[UIImage imageNamed:images[1]] forState:UIControlStateNormal];
    } else if (images.count == 3) {
        [_btn1 setImage:[UIImage imageNamed:images[0]] forState:UIControlStateNormal];
        [_btn2 setImage:[UIImage imageNamed:images[1]] forState:UIControlStateNormal];
        [_btn3 setImage:[UIImage imageNamed:images[2]] forState:UIControlStateNormal];
    }
}

- (IBAction)didClickBtn:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickSceneBtnTag:index:)]) {
        [_delegate didClickSceneBtnTag:sender.tag index:self.index];
    }
}


@end
