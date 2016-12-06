//
//  SwtichCollectionCell.h
//  Smart_home
//
//  Created by 彭子上 on 2016/8/15.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef NS_ENUM(NSUInteger, SwitchType) {
    SwitchTypeOne   =   1,
    SwitchTypeTwo,
    SwitchTypeThree,
};

@protocol SwitchDelegate <NSObject>

-(void)didClickBtnTag:(NSUInteger)btnTag cellTag:(NSUInteger)cellTag;

//-(void)didClickFuntionBtn:(NSUInteger)tag cellTag:(NSUInteger)cellTag;

-(void)didClickEditCellTag:(NSUInteger)cellTag;

@end

@interface SwtichCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *nameBtn;
@property (weak, nonatomic) IBOutlet UILabel *macLab;

@property (assign,nonatomic) id<SwitchDelegate>delegate;


-(void)setStateImageWithBtnCount:(NSUInteger)btnCount deviceState:(NSNumber *)deviceState;




@end
