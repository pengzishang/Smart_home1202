//
//  SideBarController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/6/29.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SiderNormalCell.h"

@protocol SiderBarDelegate <NSObject>

-(void)didClickTableItem:(NSUInteger)index;
-(void)didClickLogin;

@end

@interface SideBarController : UIViewController

@property(nonatomic,assign)id <SiderBarDelegate> delegate;
@end
