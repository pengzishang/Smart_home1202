//
//  AppDelegate.h
//  Smart_home
//
//  Created by 彭子上 on 2016/6/29.
//  Copyright © 2016年 彭子上. All rights reserved.
//



#import <UIKit/UIKit.h>

#import <JFGSDK/JFGSDK.h>

//推送
static NSString *appKey = @"c50182293b5755941b0bab4e";
static NSString *channel = @"Publish channel";
static BOOL isProduction = FALSE;
//蒲公英
static NSString *pgyKey = @"5d8a11866945bfc65d775cef7d663020";//d876420c861f29257991f996db20f1ed
//可视门铃

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) NSTimer *autoScan;
@property(assign, nonatomic) BOOL isJFGLogin;
@property(strong, nonatomic) NSDictionary *pushUserInfo;
@property(strong, nonatomic) NSData *deviceToken;

@property(strong, nonatomic) UIWindow *window;

@end

