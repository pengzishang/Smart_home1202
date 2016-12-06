//
//  LaunchView.h
//  Smart_home
//
//  Created by 彭子上 on 2016/7/7.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface LaunchView : UIScrollView<UIScrollViewDelegate>

-(instancetype)initWithFrame:(CGRect)frame images:(NSArray <__kindof NSString *>*)imgNames complete:(void(^)(void))complete;

@end
