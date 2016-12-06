//
//  SceneCellCommon.h
//  Smart_home
//
//  Created by 彭子上 on 2016/9/18.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SceneCellDelegata <NSObject>

-(void)didClickSceneBtnTag:(NSUInteger)tag index:(NSIndexPath *)index;

@end

@interface SceneCellCommon : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (assign,nonatomic)id<SceneCellDelegata>delegate;

-(void)setImageWithStatus:(NSUInteger)deviceStatus deviceType:(NSUInteger)deviceType index:(NSIndexPath *)index;

@end
