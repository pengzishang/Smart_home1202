//
//  CurtainCollectionCell.h
//  Smart_home
//
//  Created by 彭子上 on 2016/8/24.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CurtainCollectionCell;
@protocol CurtainDelegate <NSObject>

-(void)didClickCurtainBtnTag:(NSUInteger)btnTag cellTag:(NSUInteger)cellTag cell:(CurtainCollectionCell *)cell;

-(void)didClickEditCellTag:(NSUInteger)cellTag;

@end

@interface CurtainCollectionCell : UICollectionViewCell

@property (assign,nonatomic)id <CurtainDelegate>delegate;

@property (assign,nonatomic)BOOL isRuning;

@property (strong,nonatomic)NSNumber *status;

@property (strong,nonatomic)NSIndexPath *indexPath;

-(void)setInformationMac:(NSString *)macID name:(NSString *)name indexPath:(NSIndexPath *)indexPath;

-(void)setNormalImage;

@end

