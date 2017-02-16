//
//  CurtainCollectionCell.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/24.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "CurtainCollectionCell.h"

@interface CurtainCollectionCell ()

@property(weak, nonatomic) IBOutlet UILabel *macID;
@property(weak, nonatomic) IBOutlet UIButton *nameBtn;
@property(weak, nonatomic) IBOutlet UIButton *leftBtn;
@property(weak, nonatomic) IBOutlet UIButton *rightBtn;


@end


@implementation CurtainCollectionCell


- (IBAction)didClickBtn:(UIButton *)sender {
    [self setNormalImage];
    if (_delegate && [_delegate respondsToSelector:@selector(didClickCurtainBtnTag:cellTag:cell:)]) {
        [_delegate didClickCurtainBtnTag:sender.tag cellTag:self.tag cell:self];
    }
}

- (IBAction)nameBtn:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickEditCellTag:)]) {
        [_delegate didClickEditCellTag:self.tag];
    }
}

- (void)setInformationMac:(NSString *)macID name:(NSString *)name indexPath:(NSIndexPath *)indexPath {
    _macID.text = macID;
    [_nameBtn setTitle:name forState:UIControlStateNormal];
    [self setNormalImage];
    self.indexPath = indexPath;
    self.tag = indexPath.row + 200;
}

- (void)setNormalImage {
    [_leftBtn setImage:[UIImage imageNamed:@"curtain_left_status_close"] forState:UIControlStateNormal];
    [_rightBtn setImage:[UIImage imageNamed:@"curtain_right_status_close"] forState:UIControlStateNormal];
}


@end
