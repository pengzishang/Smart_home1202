//
//  ChooseBrandController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/8/6.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, InfrareDeviceType) {
    InfrareDeviceTypeAir = 0,
    InfrareDeviceTypeTV,
    InfrareDeviceTypeDVD,
    InfrareDeviceTypeAMP,
    InfrareDeviceTypeBOX
};

@interface ChooseBrandController : UIViewController


@property(nonatomic, strong) NSMutableArray *resourseArr;
@property(nonatomic, assign) InfrareDeviceType deviceType;

@end
