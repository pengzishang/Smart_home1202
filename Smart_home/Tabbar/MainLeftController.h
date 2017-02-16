//
//  MainLeftController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/6/29.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <MMDrawerController/MMDrawerController.h>

@protocol MainDelegate <NSObject>

@optional

- (void)didFinishAdding;

- (void)didClickSceneIndex:(NSUInteger)index;

- (void)willEditSceneIndex:(NSUInteger)index;

- (void)willOpenVideo:(NSDictionary *)userinfo;

@end

@interface MainLeftController : MMDrawerController

@property(nonatomic, assign) BOOL isLeftOpen;
@property(assign, nonatomic) id <MainDelegate> delegate;
@end
