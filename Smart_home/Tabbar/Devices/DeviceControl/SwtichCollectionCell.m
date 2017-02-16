//
//  SwtichCollectionCell.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/15.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "SwtichCollectionCell.h"

@implementation SwtichCollectionCell

- (void)setStateImageWithBtnCount:(NSUInteger)btnCount deviceState:(NSNumber *)deviceState {
    NSArray *btnImage = [self stateImageReturn:btnCount deviceState:deviceState];
    if (!btnImage) {
        return;
    }
    if (btnCount == 0 && btnImage.count == 1) {
        UIButton *btn1 = [self viewWithTag:1001];
        [btn1 setImage:[UIImage imageNamed:btnImage[0]] forState:UIControlStateNormal];
    } else if (btnCount == 1) {
        UIButton *btn1 = [self viewWithTag:1001];
        [btn1 setImage:[UIImage imageNamed:btnImage[0]] forState:UIControlStateNormal];
    } else if (btnCount == 2 && btnImage.count == 2) {
        UIButton *btn1 = [self viewWithTag:1001];
        UIButton *btn2 = [self viewWithTag:1002];
        [btn1 setImage:[UIImage imageNamed:btnImage[0]] forState:UIControlStateNormal];
        [btn2 setImage:[UIImage imageNamed:btnImage[1]] forState:UIControlStateNormal];
    } else if (btnCount == 3 && btnImage.count == 3) {
        UIButton *btn1 = [self viewWithTag:1001];
        UIButton *btn2 = [self viewWithTag:1004];
        UIButton *btn3 = [self viewWithTag:1002];
        [btn1 setImage:[UIImage imageNamed:btnImage[0]] forState:UIControlStateNormal];
        [btn2 setImage:[UIImage imageNamed:btnImage[1]] forState:UIControlStateNormal];
        [btn3 setImage:[UIImage imageNamed:btnImage[2]] forState:UIControlStateNormal];
    }
}

- (NSArray *)stateImageReturn:(NSUInteger)btnCount deviceState:(NSNumber *)deviceState {
    if ([deviceState isEqualToNumber:@(-1)]) {
        deviceState = @(0);
    }
    switch (btnCount) {
        case 0: {
            if ([deviceState isEqualToNumber:@(0)]) {
                return @[@"socket_state_off"];
            } else if ([deviceState isEqualToNumber:@(1)]) {
                return @[@"socket_state_on"];
            } else {
                return @[@""];
            }
        }
            break;
        case 1: {
            if ([deviceState isEqualToNumber:@(0)]) {
                return @[@"switch1_state_off"];
            } else if ([deviceState isEqualToNumber:@(1)]) {
                return @[@"switch1_state_on"];
            } else if ([deviceState isEqualToNumber:@(4)]) {//工厂错误
                return @[@"switch1_state_off"];
            } else if ([deviceState isEqualToNumber:@(5)]) {//工厂错误
                return @[@"switch1_state_on"];
            } else {
                return @[@""];
            }
        }
            break;
        case 2: {
            if ([deviceState isEqualToNumber:@0]) {
                return @[@"switch2_left_state_off", @"switch2_right_state_off"];
            } else if ([deviceState isEqualToNumber:@1]) {
                return @[@"switch2_left_state_on", @"switch2_right_state_off"];
            } else if ([deviceState isEqualToNumber:@2]) {
                return @[@"switch2_left_state_off", @"switch2_right_state_on"];
            } else if ([deviceState isEqualToNumber:@3]) {
                return @[@"switch2_left_state_on", @"switch2_right_state_on"];
            } else {
                return @[@""];
            }
        }
            break;
        case 3: {
            if ([deviceState isEqualToNumber:@0]) {
                return @[@"switch3_left_state_off", @"switch3_mid_state_off", @"switch3_right_state_off"];
            } else if ([deviceState isEqualToNumber:@1]) {
                return @[@"switch3_left_state_on", @"switch3_mid_state_off", @"switch3_right_state_off"];
            } else if ([deviceState isEqualToNumber:@4]) {//工厂错误
                return @[@"switch3_left_state_off", @"switch3_mid_state_on", @"switch3_right_state_off"];
            } else if ([deviceState isEqualToNumber:@5]) {//工厂错误
                return @[@"switch3_left_state_on", @"switch3_mid_state_on", @"switch3_right_state_off"];
            } else if ([deviceState isEqualToNumber:@2]) {//工厂错误
                return @[@"switch3_left_state_off", @"switch3_mid_state_off", @"switch3_right_state_on"];
            } else if ([deviceState isEqualToNumber:@3]) {//工厂错误
                return @[@"switch3_left_state_on", @"switch3_mid_state_off", @"switch3_right_state_on"];
            } else if ([deviceState isEqualToNumber:@6]) {
                return @[@"switch3_left_state_off", @"switch3_mid_state_on", @"switch3_right_state_on"];
            } else if ([deviceState isEqualToNumber:@7]) {
                return @[@"switch3_left_state_on", @"switch3_mid_state_on", @"switch3_right_state_on"];
            } else {
                return @[@""];
            }
        }
            break;
        default:
            return @[@""];
            break;
    }
}

- (IBAction)didClickSwitchBtn:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickBtnTag:cellTag:)]) {
        [_delegate didClickBtnTag:sender.tag cellTag:self.tag];
    }
}

- (IBAction)didClickEdit:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickEditCellTag:)]) {
        [_delegate didClickEditCellTag:self.tag];
    }
}


@end
