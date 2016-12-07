//
//  TTSUtility.m
//  ttsBluetooth_iPhone
//
//  Created by tts on 14-9-16.
//  Copyright (c) 2014年 tts. All rights reserved.
//

#import "TTSUtility.h"
#import "NSString+StringOperation.h"


#import <JFGSDK/JFGSDKDataPoint.h>



@implementation TTSUtility



/**
 *  开始一段屏幕提示
 *
 *  @param mainTitle <#mainTitle description#>
 *  @param subTitle  <#subTitle description#>
 */
+(void)startAnimationWithMainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle
{
    UIView *frontView=[TTSUtility getCurrentView];
    MBProgressHUD *hud=[frontView viewWithTag:10001];
    if (!hud) {
        hud=[[MBProgressHUD alloc]initWithView:frontView];
        hud.tag=10001;
        [hud setRemoveFromSuperViewOnHide:YES];
        [hud showAnimated:YES];
        [frontView addSubview:hud];
    }
    hud.label.text=mainTitle;
    hud.detailsLabel.text=subTitle;
}

/**
 *  停止一段屏幕动画
 *
 *  @param mainTitle <#mainTitle description#>
 *  @param subTitle  <#subTitle description#>
 */
+(void)stopAnimationWithMainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle
{
    UIView *frontView=[TTSUtility getCurrentView];
    MBProgressHUD *hud=(MBProgressHUD *)[frontView viewWithTag:10001];
    hud.label.text=mainTitle;
    hud.detailsLabel.text=subTitle;
    [hud hideAnimated:YES afterDelay:1.5];
    [TTSUtility shake];
}

/**
 *  一段短暂显示的动画
 *
 *  @param time      <#time description#>
 *  @param mainTitle <#mainTitle description#>
 *  @param subTitle  <#subTitle description#>
 */

+(void)showForShortTime:(NSUInteger)time mainTitle:(NSString *)mainTitle subTitle:(NSString *)subTitle
{
    UIView *frontView=[TTSUtility getCurrentView];
    MBProgressHUD *hud=[frontView viewWithTag:10001];
    if (!hud) {
        hud=[[MBProgressHUD alloc]initWithView:frontView];
        hud.tag=10001;
        [hud setRemoveFromSuperViewOnHide:YES];
        [hud showAnimated:YES];
        [frontView addSubview:hud];
    }
    hud.label.text=mainTitle;
    hud.detailsLabel.text=subTitle;
    [hud hideAnimated:YES afterDelay:time];
    [TTSUtility shake];
}

//添加多个设备
+(void)addMutiDeviceAnimationFinish:(void (^)(void))finish
{
    UIView *frontView=[TTSUtility getCurrentView];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:frontView animated:YES];
    hud.label.text = NSLocalizedString(@"准备中...", @"HUD preparing title");
    hud.minSize = CGSizeMake(150.f, 100.f);
    [hud setRemoveFromSuperViewOnHide:YES];
    hud.tag=10001;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [[BluetoothManager getInstance]scanPeriherals:NO AllowPrefix:@[@(ScanTypeOther),@(ScanTypeSocket),@(ScanTypeSwitch),@(ScanTypeCurtain),@(ScanTypeWarning)]];
        sleep(3);
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.mode = MBProgressHUDModeDeterminate;
            hud.label.text = NSLocalizedString(@"Loading...", @"HUD loading title");
        });
        
        NSArray <NSDictionary *>*allDeviceList=[NSArray arrayWithArray:[BluetoothManager getInstance].peripheralsInfo];
        __block CGFloat progress=0.0f;
        NSArray <DeviceInfo *>*allStoreList=[[TTSCoreDataManager getInstance]getResultArrWithEntityName:@"DeviceInfo" predicate:nil];
        
        __block NSMutableSet <DeviceInfo *>*allRoomInfo=[NSMutableSet set];
        [allDeviceList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            progress+=1.0f/allDeviceList.count;
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.progress = progress;
                hud.label.text=[NSString stringWithFormat:@"进度:%zd/%zd",idx,allDeviceList.count-1];
            });
            
            NSString *deviceName = obj[AdvertisementData][@"kCBAdvDataLocalName"];
            __block BOOL isContain=NO;
            [allStoreList enumerateObjectsUsingBlock:^(DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([[deviceName substringFromIndex:7]isEqualToString:obj.deviceMacID]) {
                    isContain=YES;
                    *stop=YES;
                }
            }];
            
            if (isContain) {
                return ;
            }
            
            BOOL isOldDevice=[deviceName hasPrefix:@"Switch"]||[deviceName hasPrefix:@"Socket"];
            BOOL isBigRemote=[deviceName hasPrefix:@"Rem-53"]||[deviceName hasPrefix:@"Rem-Da"];
            
            NSString *deviceType=isOldDevice?[deviceName substringWithRange:NSMakeRange(7, 1)]:[deviceName substringWithRange:NSMakeRange(4, 2)];
            if ([deviceName hasPrefix:@"Rem-53"]||[deviceName hasPrefix:@"Rem-Da"]) {
                deviceType=isBigRemote?@"53":@"54";//遥控器的例外i
            }
            if (deviceType.integerValue>=21) {
                deviceType=@(deviceType.integerValue-20).stringValue;
            }
            
            if (deviceType.integerValue>=11&&deviceType.integerValue<=13) {
                deviceType=@(deviceType.integerValue-10).stringValue;
            }
            
            NSString *deviceIDstr=[deviceName substringFromIndex:7];
            NSNumber *deviceStateCode=obj[@"stateCode"];
            
            if (deviceType.integerValue==2) {
                deviceStateCode= @(deviceStateCode.integerValue&0x03);
            }
            else if (deviceType.integerValue==1){
                deviceStateCode= @(deviceStateCode.integerValue&0x01);
            }
            else{
                deviceStateCode=deviceStateCode;
            }
            
            NSDictionary *devicesInfoDic=@{@"deviceMacID":deviceIDstr,@"deviceCustomName":deviceName,@"deviceType":deviceType,@"deviceStatus":deviceStateCode};
            DeviceInfo *deviceInfo = (DeviceInfo *)[[TTSCoreDataManager getInstance]getNewManagedObjectWithEntiltyName:@"DeviceInfo"];
            [deviceInfo setValuesForKeysWithDictionary:devicesInfoDic];
            if ([deviceName hasPrefix:@"Switch"]) {
                deviceInfo.deviceCustomName=[NSString stringWithFormat:@"%@:%@",[NSString ListNameWithPrefix:[deviceName substringToIndex:8]],[deviceIDstr substringFromIndex:deviceIDstr.length-4]];
            }
            else{
                deviceInfo.deviceCustomName=[NSString stringWithFormat:@"%@:%@",[NSString ListNameWithPrefix:[deviceName substringToIndex:7]],[deviceIDstr substringFromIndex:deviceIDstr.length-4]];
            }
            
            deviceInfo.deviceCreateDate=[NSDate date];
            if (RemoteDefault) {
                deviceInfo.deviceRemoteMac=RemoteDefault;
            }
            deviceInfo.deviceTapCount=@(0);
            deviceInfo.isCommonDevice=@(YES);
            
            
            usleep(50000);
            [allRoomInfo addObject:deviceInfo];
            [[TTSCoreDataManager getInstance]insertDataWithObject:deviceInfo];
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.label.text = NSLocalizedString(@"整理中...", @"HUD cleanining up title");
            NSArray <RoomInfo *>*rooms=[[TTSCoreDataManager getInstance]getResultArrWithEntityName:@"RoomInfo" predicate:nil];
            [rooms enumerateObjectsUsingBlock:^(RoomInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.roomType isEqualToNumber:@10]) {
                    obj.deviceInfo=allRoomInfo;
                    [[TTSCoreDataManager getInstance]updateData];
                    *stop=YES;
                    
                }
            }];
        });
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            if (finish) {
                finish();
            }
        });
    });
    
}

/**
 *  得到当前最顶层VC
 *
 *  @return <#return value description#>
 */
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

+ (UIView *)getCurrentView
{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    return [window subviews][0];
}


+ (UIViewController *)getTopVC
{
    MainLeftController *s=[TTSUtility getCurrentDrawerControl];
    TTSTabBarController *ss=(TTSTabBarController *)s.centerViewController;
    UINavigationController *sss=[ss viewControllers][0];
    return sss.topViewController;
}

+(MainLeftController *)getCurrentDrawerControl
{
    UIViewController * rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [rootVC isKindOfClass:[MainLeftController class]]?
    (MainLeftController *)rootVC:
    (MainLeftController *)rootVC.presentedViewController;
}

//根据指定时间的字符串格式和时间 格式例如yyyy-MM-dd HH:mm:ss:SSS
+ (NSString *) stringDateByFormatString:(NSString *) formatString withDate:(NSDate *)date
{
    if (date == nil) {
        return @"";
    }
    NSDateFormatter * dateFromatter=[[NSDateFormatter alloc] init];
    //[dateFromatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFromatter setTimeStyle:NSDateFormatterLongStyle];
    if(formatString!=nil)
    {
        [dateFromatter setDateFormat:formatString];
    }
    NSString * strDate=[dateFromatter stringFromDate:date];
    return strDate;
}

/**
 *  震动
 */
+ (void)shake
{
    NSString * deviceType =  [[UIDevice currentDevice]model];
    if ([deviceType isEqualToString:iPhone] || [deviceType isEqualToString:@"iPod"]) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    else if([deviceType isEqualToString:iPad]){
        [TTSUtility playSoundWithName:@"switch_21.mp3"];
    }
    //            [TTSUtility playSoundWithName:@"switch_21.mp3"];
    
}


/**
 *  播放声音
 *
 *  @param fileName <#fileName description#>
 */
+ (void)playSoundWithName:(NSString *)fileName
{
    //    NSString * filePath  = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle]bundlePath],fileName];
    
    //    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"door" ofType:@"mp3"];
    //    //    NSString *filePath =@"/Users/pengzishang/Desktop/Smart_home(9.17)/Smart_home/door.mp3";
    //    player = [[AVAudioPlayer alloc]initWithContentsOfURL:
    //              [NSURL fileURLWithPath:filePath] error:NULL];
    //    [player prepareToPlay];//分配播放所需的资源，并将其加入内部播放队列
    //    [player play];//播放
    
    
    //    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //    NSError *error = nil;
    //    BOOL b = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    //    if (b)
    //    {
    //        AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
    //        player.volume = 1.0;
    //        [player prepareToPlay];
    //        [player play];
    //    }
}
//
////刷新数据库中状态
//+ (void)refreshDataBaseWithDeviceID:(NSString *)deviceMacID stateCode:(NSNumber *)stateCode
//{
//    NSArray *result = [[TTSCoreDataManager getInstance] getResultArrWithEntityName:@"DeviceInfo" predicate:nil];
//    [result enumerateObjectsUsingBlock:^(DeviceInfo *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if(obj.roomInfo){
//            if ([deviceMacID isEqualToString:obj.deviceMacID]) {
//                obj.deviceSceneStatus=stateCode;
//            }
//        }
//    }];
//}

//
//+ (NSString *)fetchSSIDInfo
//{
//    NSString *ssid = nil;
//    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
//    NSLog(@"Supported interfaces: %@", ifs);
//    id info = nil;
//    for (NSString *ifname in ifs) {
//        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
//        if (info[@"SSID"])
//        {
//            ssid = info[@"SSID"];
//        }
//    }
//    return info;
//}


+(NSArray *)initScene:(RoomInfo *)roomInfo
{
    //第一次添加
    //    NSLogMethodArgs(@"%@",roomInfo.deviceInfo);
    
    if (roomInfo.sceneInfo.count==0) {
        NSMutableSet *roombeforeAdd=[NSMutableSet setWithSet:roomInfo.sceneInfo];
        for (NSUInteger i=0; i<2; i++)
        {
            NSMutableSet *sceneDeviceSet=[NSMutableSet set];
            NSSet <__kindof DeviceInfo *>*roomDevices=[NSSet setWithSet:roomInfo.deviceInfo];
            
            SceneInfo *sceneInfo=(SceneInfo *)[[TTSCoreDataManager getInstance]getNewManagedObjectWithEntiltyName:@"SceneInfo"];
            sceneInfo.sceneType=@(i);
            sceneInfo.sceneTapCount=@(0);
            sceneInfo.sceneCreateDate=[NSDate date];
            sceneInfo.sceneName=i==0?@"全关":@"全开";
            [[TTSCoreDataManager getInstance]insertDataWithObject:sceneInfo];
            
            [roomDevices enumerateObjectsUsingBlock:^(__kindof DeviceInfo * _Nonnull roomDeviceObj, BOOL * _Nonnull stop) {
                if ((roomDeviceObj.deviceType.integerValue <=5&&roomDeviceObj.deviceType.integerValue >=0)||(roomDeviceObj.deviceType.integerValue<=23&&roomDeviceObj.deviceType.integerValue>20)) {
                    DeviceForScene *sceneOfDevice= (DeviceForScene *)[[TTSCoreDataManager getInstance]getNewManagedObjectWithEntiltyName:@"DeviceForScene"];
                    sceneOfDevice.deviceType=@(roomDeviceObj.deviceType.integerValue);
                    sceneOfDevice.deviceMacID=roomDeviceObj.deviceMacID;
                    sceneOfDevice.deviceCustomName=roomDeviceObj.deviceCustomName;
                    if (i==0) {//全关
                        if(sceneOfDevice.deviceType.integerValue==4||sceneOfDevice.deviceType.integerValue==5){
                            sceneOfDevice.deviceSceneStatus=@"2";
                        }
                        else
                        {
                            sceneOfDevice.deviceSceneStatus=@"0";
                        }
                        
                    }
                    else if (i==1){//全开
                        if(sceneOfDevice.deviceType.integerValue==4||sceneOfDevice.deviceType.integerValue==5||sceneOfDevice.deviceType.integerValue==0){
                            sceneOfDevice.deviceSceneStatus=@"1";
                        }
                        else
                        {
                            NSInteger j=pow(2,sceneOfDevice.deviceType.integerValue)-1;
                            sceneOfDevice.deviceSceneStatus=@(j).stringValue;
                        }
                    }
                    [[TTSCoreDataManager getInstance]insertDataWithObject:sceneOfDevice];
                    [sceneDeviceSet addObject:sceneOfDevice];
                }
            }];
            
            
            sceneInfo.devicesInfo=sceneDeviceSet;
            [[TTSCoreDataManager getInstance]updateData];
            [roombeforeAdd addObject:sceneInfo];
            
        }
        roomInfo.sceneInfo=[NSSet setWithSet:roombeforeAdd] ;//更新房间的Scene
        [[TTSCoreDataManager getInstance]updateData];
    }
    
    NSSortDescriptor *sortByDate=[[NSSortDescriptor alloc]initWithKey:@"sceneCreateDate" ascending:YES];
    NSArray *sceneReturn=[roomInfo.sceneInfo sortedArrayUsingDescriptors:@[sortByDate]];
    
    return sceneReturn;
}

+(SceneInfo *)addSceneWithRoom:(RoomInfo *)roomInfo index:(NSUInteger)roomIndex roomName:(NSString *)roomName
{
    NSMutableSet *roomSceneSet=[NSMutableSet setWithSet:roomInfo.sceneInfo];
    NSMutableSet *sceneDeviceSet=[NSMutableSet set];
    [roomInfo.deviceInfo enumerateObjectsUsingBlock:^(DeviceInfo * _Nonnull roomDeviceObj, BOOL * _Nonnull stop) {
        if ((roomDeviceObj.deviceType.integerValue <=5&&roomDeviceObj.deviceType.integerValue >=0)||(roomDeviceObj.deviceType.integerValue<=23&&roomDeviceObj.deviceType.integerValue>20)) {
            DeviceForScene *sceneOfDevice= (DeviceForScene *)[[TTSCoreDataManager getInstance]getNewManagedObjectWithEntiltyName:@"DeviceForScene"];
            sceneOfDevice.deviceType=@(roomDeviceObj.deviceType.integerValue);
            sceneOfDevice.deviceMacID=roomDeviceObj.deviceMacID;
            sceneOfDevice.deviceCustomName=roomDeviceObj.deviceCustomName;
            [sceneDeviceSet addObject:sceneOfDevice];
            if(sceneOfDevice.deviceType.integerValue==4||sceneOfDevice.deviceType.integerValue==5){
                sceneOfDevice.deviceSceneStatus=@"2";
            }
            else
            {
                sceneOfDevice.deviceSceneStatus=@"0";
            }
        }
    }];
    SceneInfo *sceneInfo=(SceneInfo *)[[TTSCoreDataManager getInstance]getNewManagedObjectWithEntiltyName:@"SceneInfo"];
    sceneInfo.sceneType=@(roomIndex);
    sceneInfo.sceneTapCount=@(0);
    sceneInfo.sceneCreateDate=[NSDate date];
    sceneInfo.sceneName=roomName;
    sceneInfo.devicesInfo=sceneDeviceSet;
    [[TTSCoreDataManager getInstance]insertDataWithObject:sceneInfo];
    [roomSceneSet addObject:sceneInfo];
    roomInfo.sceneInfo=roomSceneSet;
    [[TTSCoreDataManager getInstance]updateData];
    return sceneInfo;
}

+ (void)deleteScene:(SceneInfo *)sceneInfo room:(RoomInfo *)roomInfo
{
    NSMutableSet *roomSceneSet=[NSMutableSet setWithSet:roomInfo.sceneInfo];
    [roomSceneSet removeObject:sceneInfo];
    roomInfo.sceneInfo=roomSceneSet;
    [[TTSCoreDataManager getInstance]deleteDataWithObject:sceneInfo];
    [[TTSCoreDataManager getInstance]updateData];
}



+(void)newGuideWithPoint:(CGPoint)point title:(NSString *)title
{
    CGRect frame = [UIScreen mainScreen].bounds;
    UIView * bgView = [[UIView alloc]initWithFrame:frame];
    bgView.backgroundColor = [UIColor grayColor];
    bgView.layer.opacity=0.6;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sureTapClick:)];
    [bgView addGestureRecognizer:tap];
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
    // 这里添加第二个路径 （这个是圆）
    [path appendPath:[UIBezierPath bezierPathWithArcCenter:point radius:40 startAngle:0 endAngle:2*M_PI clockwise:NO]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [bgView.layer setMask:shapeLayer];
}

+(void)openVideo:(id)userInfo
{
    MainLeftController *main=[TTSUtility getCurrentDrawerControl];
    [main performSegueWithIdentifier:@"getcalling" sender:userInfo];
}


- (void)sureTapClick:(UITapGestureRecognizer *)tap
{
    UIView * view = tap.view;
    [view removeFromSuperview];
    [view removeGestureRecognizer:tap];
}

/**
 *  加入半透明图层
 *
 *  @param tag  <#tag description#>
 *  @param view <#view description#>
 *
 *  @return <#return value description#>
 */
+(UIView *)addBlurWithtag:(NSUInteger)tag view:(UIView *)view
{
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.frame = view.window.frame;
    effectview.tag=tag;
    effectview.alpha=0;
    [view.window addSubview:effectview];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        effectview.alpha=1.0;
    } completion:nil];
    
    return effectview;
}

/**
 *  加入编辑设备界面
 *
 *  @param view   <#view description#>
 *  @param device <#device description#>
 *
 *  @return <#return value description#>
 */

+(UIView *)addWindowsWithNibNamed:(NSString *)nibName OnView:(UIView *)view
{
    UIView *blackGround=[[UIView alloc]initWithFrame:Screen_Frame];
    blackGround.tag=2000;
    blackGround.backgroundColor=[UIColor colorWithRed:0x00/0xff green:0x00/0xff blue:0x00/0xff alpha:0.5];
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:blackGround];
    UIView *addView=[[[NSBundle mainBundle]loadNibNamed:nibName owner:self options:nil]firstObject];
    addView.center=view.center;
    addView.layer.cornerRadius=6.0;
    addView.clipsToBounds=YES;
    [blackGround addSubview:addView];
    return addView;
}


+(RoomInfo *)addRoomWithName:(NSString *)roomName roomType:(NSNumber *)roomType
{
    NSDate * curDate = [NSDate date];
    RoomInfo * roomInfo = (RoomInfo *)[[TTSCoreDataManager getInstance]getNewManagedObjectWithEntiltyName:@"RoomInfo"];
    roomInfo.roomName = roomName;
    roomInfo.roomCreateDate = curDate;
    roomInfo.roomTapCount = @0;
    roomInfo.isCommonRoom = @NO;
    if ([roomType isEqualToNumber:@10]) {
        roomInfo.isCommonRoom = @YES;
        NSArray *devices=[[TTSCoreDataManager getInstance]getResultArrWithEntityName:@"DeviceInfo" predicate:nil];
        roomInfo.deviceInfo=[NSSet setWithArray:devices];
    }
    roomInfo.roomType=roomType;
    [[TTSCoreDataManager getInstance]insertDataWithObject:roomInfo];
    return roomInfo;
}

#pragma mark 电子锁

/**
 *  电子锁本地控制
 *
 *  @param deviceInfo 蓝牙设备的DeviceInfo
 *  @param lockMode   锁的模式
 *  @param passWord   密码
 */

+(void)lockWithDeviceInfo:(DeviceInfo *)deviceInfo lockMode:(APPLockMode)lockMode passWord:(NSString *)passWord validtime:(NSTimeInterval)validtime;
{
    [TTSUtility startAnimationWithMainTitle:NSLocalizedString(@"正在控制", @"正在控制") subTitle:[NSString stringWithFormat:NSLocalizedString(@"控制ID:%@", @"控制ID:%@"), deviceInfo.deviceMacID]];
    
    NSString *APPOpertingEnterCommandPrefix=[NSString stringWithFormat:@"00%zd",lockMode];
    NSString *APPOpertingEnterCommandAll=@"";
    switch (lockMode) {
            //酒店项目实现Open方法就可以了
        case APPLockModeOpen:
        case APPLockModeChange:
        case APPLockModeCleanAll: {
            APPOpertingEnterCommandAll=[APPOpertingEnterCommandPrefix stringByAppendingString:
                                        [NSString initWithDate:[NSDate dateWithTimeIntervalSinceNow:validtime] isRemote:NO]];
            APPOpertingEnterCommandAll=[APPOpertingEnterCommandAll stringByAppendingString:
                                        [NSString convertPassWord:passWord]];
            break;
        }
        case APPLockModeSync: {
            APPOpertingEnterCommandAll=[APPOpertingEnterCommandPrefix stringByAppendingString:
                                        [NSString initWithDate:[NSDate date] isRemote:NO]];
            APPOpertingEnterCommandAll =[APPOpertingEnterCommandAll stringByAppendingString:@"000000000"];//后三个0
            break;
        }
        default:
            break;
            
    }
    //处理密码操作
    NSLogMethodArgs(@"%@",APPOpertingEnterCommandAll);
    
    [[BluetoothManager getInstance]sendByteCommandWithString:APPOpertingEnterCommandAll deviceID:deviceInfo.deviceMacID sendType:SendTypeLock success:^(NSData * _Nullable stateData) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制成功", @"控制成功") subTitle:@""];
    } fail:^NSUInteger(NSString * _Nullable stateString) {
        NSDictionary *errorCode=@{@"404":@"控制距离太远,设备不在范围",@"103":@"未发现服务",@"104":@"写入数据失败",@"106":@"未得到回应",@"102":@"连接设备失败",@"403":@"手机蓝牙未开启",@"107":@"被设备异常断开,设备中途异常端口"};
        NSString *errorNotice=errorCode[stateString];
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制失败", @"控制失败") subTitle:errorNotice];
        return 0;
    }];
}

+(void)lockWithRemoteInfo:(DeviceInfo *)lockInfo lockMode:(APPLockMode)lockMode passWord:(NSString *)passWord validtime:(NSTimeInterval)validtime
{
    [TTSUtility startAnimationWithMainTitle:NSLocalizedString(@"正在远程控制", @"正在远程控制") subTitle:[NSString stringWithFormat:NSLocalizedString(@"控制ID:%@", @"控制ID:%@"), lockInfo.deviceMacID]];
    //1开锁
    [[RemoteManger getInstance]sendLockRemotePassword:passWord lockID:lockInfo.deviceMacID Methods:1 success:^(NSString *statusCode) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制成功", @"控制成功") subTitle:@""];
    } fail:^NSUInteger(NSString *statusCode) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制失败", @"控制失败") subTitle:NSLocalizedString(@"控制距离太远或者设备不在附近", @"控制距离太远或者设备不在附近")];
        return 0;
    }];
}


/**
 *  链接触发设备
 *
 *  @param deviceID <#deviceID description#>
 *  @param lockInfo <#lockInfo description#>
 */
+(void)lockWithLinkDevice:(NSString *)deviceMacID lockInfo:(DeviceInfo *)lockInfo command:(NSString *)command
{
    NSString *APPOpertingEnterCommandAll=[NSString stringWithFormat:@"008%@%@000000",deviceMacID,command];
    [[BluetoothManager getInstance]sendByteCommandWithString:APPOpertingEnterCommandAll deviceID:lockInfo.deviceMacID sendType:SendTypeLock success:^(NSData * _Nullable stateData) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制成功", @"控制成功") subTitle:@""];
    } fail:^NSUInteger(NSString * _Nullable stateString) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制失败", @"控制失败") subTitle:NSLocalizedString(@"控制距离太远或者设备不在附近", @"控制距离太远或者设备不在附近")];
        return 0;
    }];
}
/**
 *  锁的电池相关
 *
 *  @param lockInfo <#lockInfo description#>
 *  @param lockMode <#lockMode description#>
 *  @param val      <#val description#>
 */
+(void)lockWithPowerLockInfo:(DeviceInfo *)lockInfo lockMode:(APPLockMode)lockMode powerWarning:(NSInteger)val
{
    NSString *APPOpertingEnterCommandPrefix=[NSString stringWithFormat:@"0%zd",lockMode];
    NSString *APPOpertingEnterCommandAll=@"";
    NSString *powVal=[[NSString stringWithFormat:@"%zd",val] fullWithLengthCount:3];
    switch (lockMode) {
        case APPLockModeLowPower: {
            APPOpertingEnterCommandAll=[NSString stringWithFormat:@"%@%@000000000000000000000000",APPOpertingEnterCommandPrefix,powVal];
            break;
        }
        case APPLockModePowerValue: {
            APPOpertingEnterCommandAll=[NSString stringWithFormat:@"%@000000000000000000000000000",APPOpertingEnterCommandPrefix];
            break;
        }
        default:
            break;
    }
    [[BluetoothManager getInstance]sendByteCommandWithString:APPOpertingEnterCommandAll deviceID:lockInfo.deviceMacID sendType:SendTypeLock success:^(NSData * _Nullable stateData) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制成功", @"控制成功") subTitle:@""];
    } fail:^NSUInteger(NSString * _Nullable stateString) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制失败", @"控制失败") subTitle:NSLocalizedString(@"控制距离太远或者设备不在附近", @"控制距离太远或者设备不在附近")];
        return 0;
    }];
    
}
/**
 *  打印日志
 *
 *  @param lockInfo <#lockInfo description#>
 */
+(void)lockWithQueryLogLockInfo:(DeviceInfo *)lockInfo
{
    
    NSString *APPOpertingEnterCommandAll=@"013000000000000000000000000000";
    [[BluetoothManager getInstance]sendByteCommandWithString:APPOpertingEnterCommandAll deviceID:lockInfo.deviceMacID sendType:SendTypeLock success:^(NSData * _Nullable stateData) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制成功", @"控制成功") subTitle:@""];
    } fail:^NSUInteger(NSString * _Nullable stateString) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制失败", @"控制失败") subTitle:NSLocalizedString(@"控制距离太远或者设备不在附近", @"控制距离太远或者设备不在附近")];
        return 0;
    }];
}

+(void)lockWithSystemInfo:(DeviceInfo *)lockInfo codeReturn:(void (^)(NSData *))codeReturn
{
    static NSUInteger failRetryTime=0;
    [TTSUtility startAnimationWithMainTitle:NSLocalizedString(@"正在控制", @"正在控制") subTitle:[NSString stringWithFormat:NSLocalizedString(@"控制ID:%@", @"控制ID:%@"), lockInfo.deviceMacID]];
    [[BluetoothManager getInstance]queryDeviceStatus:lockInfo success:^(NSData * _Nullable stateData)
     {
         failRetryTime=0;
         [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制成功", @"控制成功") subTitle:[NSString stringWithFormat:NSLocalizedString(@"控制反馈代码:%@", @"控制反馈代码:%@"),stateData]];
         if (codeReturn) {
             codeReturn(stateData);
         }
     } fail:^NSUInteger(NSString * _Nullable statusCode) {
         NSLog(@"失败返回数据:%@",statusCode);
         if (++failRetryTime<3&&[statusCode integerValue]!=404&&[statusCode integerValue]!=403) {
             [TTSUtility startAnimationWithMainTitle:NSLocalizedString(@"正在重试", @"正在重试") subTitle:[NSString stringWithFormat:NSLocalizedString(@"第%zd次重试", @"第%zd次重试"), failRetryTime]];
             return failRetryTime;
         }
         else
         {
             failRetryTime=0;
             NSDictionary *errorDetail=@{@"404":@"设备不在范围内,或者信号太弱",@"403":@"蓝牙未开启",@"102":@"连接设备失败,请重试",@"103":@"未能发现服务",@"104":@"数据写入失败",@"107":@"异常断开,设备中途主动断开,如果控制失效,请重试一次"};
             [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制失败", @"控制失败") subTitle:errorDetail[statusCode]];
             NSData *statusCodeData=[statusCode dataUsingEncoding:NSUTF8StringEncoding];
             if (codeReturn) {
                 codeReturn(statusCodeData);
             }
             return 0;
         }
     }];
}


#pragma mark 控制接口二次封装

/**
 *  本地蓝牙控制
 *
 *  @param deviceID       <#deviceID description#>
 *  @param command        <#command description#>
 *  @param subSwitchCount <#subSwitchCount description#>
 *  @param retryTimes     <#retryTimes description#>
 *  @param getStateCode   <#getStateCode description#>
 */
+(void)localDeviceControl:(NSString *)deviceMacID commandStr:(NSString *)command  retryTimes:(NSUInteger)retryTimes conditionReturn:(void (^)(id))getStateCode
{
    static NSUInteger failRetryTime=0;
    if (deviceMacID.length<12||command.length==0) {
        [TTSUtility showForShortTime:1 mainTitle:@"请先指定设备" subTitle:@"MAC为空或者命令错误"];
        return;
    }
    [TTSUtility startAnimationWithMainTitle:NSLocalizedString(@"正在控制", @"正在控制") subTitle:[NSString stringWithFormat:NSLocalizedString(@"控制ID:%@", @"控制ID:%@"), deviceMacID]];
    [[BluetoothManager getInstance]sendByteCommandWithString:command deviceID:deviceMacID sendType:SendTypeSingle
                                                     success:^(NSData * _Nullable stateData) {
                                                         failRetryTime=0;
                                                         [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制成功", @"控制成功") subTitle:[NSString stringWithFormat:NSLocalizedString(@"控制反馈代码:%@", @"控制反馈代码:%@"),stateData]];
                                                         if (getStateCode) {
                                                             getStateCode(stateData);
                                                         }
                                                     } fail:^NSUInteger(NSString * _Nullable stateString) {
                                                         NSLog(@"失败返回数据:%@",stateString);
                                                         if (++failRetryTime<retryTimes&&[stateString integerValue]!=404&&[stateString integerValue]!=403) {
                                                             [TTSUtility startAnimationWithMainTitle:NSLocalizedString(@"正在重试", @"正在重试") subTitle:[NSString stringWithFormat:NSLocalizedString(@"第%zd次重试", @"第%zd次重试"), failRetryTime]];
                                                             return failRetryTime;
                                                         }
                                                         else
                                                         {
                                                             failRetryTime=0;
                                                             NSDictionary *errorDetail=@{@"404":@"设备不在范围内,或者信号太弱",@"403":@"蓝牙未开启",@"102":@"连接设备失败,请重试",@"103":@"未能发现服务",@"104":@"数据写入失败",@"107":@"被设备异常断开,设备中途异常端口",@"106":@"控制结果异常"};
                                                             [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制失败", @"控制失败") subTitle:errorDetail[stateString]];
                                                             if(getStateCode){
                                                                 getStateCode(stateString);
                                                             }
                                                             return 0;
                                                         }
                                                     }];
}


/**
 *  本地蓝牙多控制
 *
 *  @param devices <#devices description#>
 */
+(void)mutiLocalDeviceControlWithDeviceInfoArr:(NSArray <DeviceForScene *>*)deviceArr result:(void (^)(NSArray * resultArr))resultArr
{
    [TTSUtility startAnimationWithMainTitle:NSLocalizedString(@"正在控制", @"正在控制") subTitle:@""];
    __block NSMutableArray *commandArr=[NSMutableArray array];
    [deviceArr enumerateObjectsUsingBlock:^(DeviceForScene *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *deviceCommand=[NSString stringWithFormat:@"%@",obj.deviceSceneStatus];
        NSNumber *deviceType=obj.deviceType;
        NSNumber *commandNum=@(deviceCommand.integerValue);
        if ([commandNum integerValue]>40) {
            deviceCommand=[NSString stringWithFormat:@"%zd",commandNum.integerValue+24];
        }
        else
        {
            deviceCommand=[NSString stringWithFormat:@"%zd",commandNum.integerValue+192];
        }
        
        NSDictionary *deviceTemp=@{@"deviceID":obj.deviceMacID,@"deviceCommand":deviceCommand,@"deviceType":deviceType};
        [commandArr addObject:deviceTemp];
    }];
    
    
    
    [[BluetoothManager getInstance]mutiCommandControlWithStringArr:commandArr resultList:^( NSArray * _Nullable  resultList ) {
        if(resultArr)
        {
            resultArr(resultList);
        }
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制成功", @"控制成功") subTitle:@""];
    }];
}




/**
 *  远程多个控制
 *
 *  @param deviceArr   <#deviceArr description#>
 *  @param remoteMacID <#remoteMacID description#>
 *  @param resultArr   <#resultArr description#>
 */

+(void)mutiRemoteControl:(NSArray <DeviceInfo *>*)deviceArr remoteMacID:(NSString *)remoteMacID result:(void (^)(NSArray *))resultArr
{
    //将ARR转换
    
    if(deviceArr.count>0)
    {
        __block NSMutableArray *commandArr=[NSMutableArray array];
        [deviceArr enumerateObjectsUsingBlock:^(DeviceInfo *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *deviceCommand=[NSString stringWithFormat:@"%@",obj.deviceSceneStatus];
            if ([deviceCommand integerValue]<40) {
                NSUInteger commandTemp=deviceCommand.integerValue+70;
                if (commandTemp==70) {
                    commandTemp=67;
                }
                
                deviceCommand=[NSString stringWithFormat:@"%zd",commandTemp];
            }
            NSDictionary *deviceTemp=@{@"deviceID":obj.deviceMacID,@"deviceCommand":deviceCommand};
            [commandArr addObject:deviceTemp];
        }];
        
        [TTSUtility startAnimationWithMainTitle:@"正在控制" subTitle:@""];
        [[RemoteManger getInstance]multRemoteControlWithDeviceInfoArr:commandArr result:^(NSArray *result) {
            [TTSUtility stopAnimationWithMainTitle:@"控制成功" subTitle:@""];
        }];
    }
    else
    {
        [TTSUtility showForShortTime:2 mainTitle:@"错误" subTitle:@"无任何设备被加入"];
    }
    
    
}

/**
 *  远程单个控制
 *
 *  @param deviceInfo   <#deviceInfo description#>
 *  @param command      <#command description#>
 *  @param retryTimes   <#retryTimes description#>
 *  @param getStateCode <#getStateCode description#>
 */

+(void)remoteDeviceControl:(DeviceInfo *)deviceInfo commandStr:(NSString *)command retryTimes:(NSUInteger)retryTimes conditionReturn:(void(^)(NSString *))getStateCode
{
    static NSInteger failRetryTimer=0;
    [TTSUtility startAnimationWithMainTitle:NSLocalizedString(@"正在发送远程命令", @"正在发送远程命令") subTitle:[NSString stringWithFormat:NSLocalizedString(@"控制ID:%@", @"控制ID:%@"), deviceInfo.deviceMacID]];
    [[RemoteManger getInstance]sendRemoteCommand:command deviceID:deviceInfo.deviceMacID success:^(NSString *stateCode) {
        //        [TTSUtility refreshDataBaseWithDeviceID:deviceInfo.deviceMacID stateCode:@(stateCode.integerValue)];
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制成功", @"控制成功") subTitle:@""];
        failRetryTimer=0;
        if (getStateCode) {
            getStateCode(stateCode);
        }
    } fail:^NSUInteger(NSString *stateCode) {
        NSLog(@"失败返回数据:%@",stateCode);
        failRetryTimer++;
        if (failRetryTimer<retryTimes) {
            [TTSUtility startAnimationWithMainTitle:NSLocalizedString(@"正在重试", @"正在重试") subTitle:[NSString stringWithFormat:NSLocalizedString(@"第%zd次重试", @"第%zd次重试"), failRetryTimer]];
            return failRetryTimer;
        }
        else
        {
            failRetryTimer=0;
            NSDictionary *failCode=@{@"E5":@"服务器信息超时",@"E0":@"广域网通信超时",@"E8":@"数据库中没有绑定",@"E1":@"远程控制器端网络信号不佳",@"E2":@"指令格式错误"};
            [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"远程控制失败", @"远程控制失败") subTitle:failCode[stateCode]];
            return 0;
        }
    }];
}


/**
 *  远程同步设备
 *
 *  @param deviceInfo   <#deviceInfo description#>
 *  @param remoteMacID  <#remoteMacID description#>
 *  @param getStateCode <#getStateCode description#>
 */
+(void)syncRemoteDevice:(DeviceInfo *)deviceInfo remoteMacID:(NSString *)remoteMacID conditionReturn:(void(^)(NSString *))getStateCode
{
    [TTSUtility startAnimationWithMainTitle:NSLocalizedString(@"正在远程同步", @"正在远程同步") subTitle:[NSString stringWithFormat:NSLocalizedString(@"控制ID:%@", @"控制ID:%@"), deviceInfo.deviceMacID]];
    [[RemoteManger getInstance]syncRemoteDevice:remoteMacID deviceID:deviceInfo.deviceMacID success:^(NSString *stateCode) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"同步成功", @"同步成功") subTitle:@""];
        if (getStateCode) {
            getStateCode(stateCode);
        }
    } fail:^NSUInteger(NSString *stateCode) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"同步失败", @"同步失败") subTitle:NSLocalizedString(@"原因复杂", @"原因复杂")];
        return 0;
    }];
}

+(void)mutiRemoteSave:(NSArray<DeviceInfo *> *)devices remoteMacID:(NSString *)remoteMacID
{
    __block NSMutableArray *deviceIDs=[NSMutableArray array];
    NSLogMethodArgs(@"同步的远程控制器:%@",remoteMacID);
    [devices enumerateObjectsUsingBlock:^(DeviceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.deviceMacID) {
            [deviceIDs addObject:obj.deviceMacID];
        }
    }];
    [[RemoteManger getInstance]multiSaveRemoteDevices:deviceIDs successNumberReturn:^(NSUInteger num) {
        NSLogMethodArgs(@"%zd",num);
    } remoteMac:remoteMacID];
}


+(void)switchWithBinding:(DeviceInfo *)deviceInfo ctrlNum:(NSUInteger)ctrlNum remoteID:(NSString *)remoteID
{
    //    命令字（1 byte）	NOP(1 byte)	控制字(1 byte)	ID码(6 bytes)	备用(1 byte)
    //         0x02	             nop	    ctrl	      id5~id0	        0xff
    [TTSUtility startAnimationWithMainTitle:NSLocalizedString(@"正在控制", @"正在控制") subTitle:@"同步开关中"];
    NSMutableString *fullCommand=[NSMutableString stringWithFormat:@"002000"];//前两个字符
    NSString *ctrlNumStr=[NSString stringWithFormat:@"%zd",ctrlNum];
    ctrlNumStr=[ctrlNumStr fullWithLengthCount:3];
    
    NSString *macIDTransform=[NSString convertMacID:deviceInfo.deviceMacID];
    [fullCommand appendString:ctrlNumStr];
    [fullCommand appendString:macIDTransform];
    [fullCommand appendString:@"255"];
    NSLogMethodArgs(@"%@",fullCommand);
    
    
    [TTSUtility localDeviceControl:remoteID commandStr:fullCommand retryTimes:1 conditionReturn:^(NSString *stateCode) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制成功", @"控制成功") subTitle:@"同步完成"];
        NSLog(@"%@",stateCode);
    }];
}


+(void)remoteBind:(DeviceInfo *)deviceInfo remoteCommand:(NSInteger)remoteCommand switchCommand:(NSInteger)switchCommand remoteID:(NSString *)remoteID
{
    [TTSUtility startAnimationWithMainTitle:NSLocalizedString(@"正在控制", @"正在控制") subTitle:@"同步开关中"];
    NSMutableString *fullCommand=[NSMutableString stringWithFormat:@"002"];//前1个字符
    NSString *remoteCommandNumStr=[NSString stringWithFormat:@"%zd",remoteCommand];
    remoteCommandNumStr=[remoteCommandNumStr fullWithLengthCount:3];
    
    NSString *switchCommandNumStr=[NSString stringWithFormat:@"%zd",switchCommand];
    switchCommandNumStr=[switchCommandNumStr fullWithLengthCount:3];
    
    
    NSString *macIDTransform=[NSString convertMacID:deviceInfo.deviceMacID];
    
    [fullCommand appendString:remoteCommandNumStr];
    [fullCommand appendString:switchCommandNumStr];
    [fullCommand appendString:macIDTransform];
    [fullCommand appendString:@"255"];
    NSLogMethodArgs(@"%@",fullCommand);
    
    [TTSUtility localDeviceControl:remoteID commandStr:fullCommand retryTimes:1 conditionReturn:^(NSString *stateCode) {
        [TTSUtility stopAnimationWithMainTitle:NSLocalizedString(@"控制成功", @"控制成功") subTitle:@"同步完成"];
        NSLog(@"%@",stateCode);
    }];
    
}

/**
 可视对讲
 
 @param cid 设备表示
 @param success <#success description#>
 @param failedBlock <#failedBlock description#>
 */
+(void)getVideoHistoryListWithCid:(NSString *)cid success:(void (^)(NSArray *))success failure:(void (^)(NSInteger))fail
{
    DataPointIDVerSeg *seg1 = [[DataPointIDVerSeg alloc]init];
    seg1.msgId = 401;
    seg1.version = 1;
    [[JFGSDKDataPoint sharedClient]robotGetDataWithPeer:cid msgIds:@[seg1] asc:YES limit:100 success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        NSMutableArray *historyList=[NSMutableArray array];
        if (idDataList.count>0) {
            
            NSArray *obj=[NSArray arrayWithArray:idDataList[0]];
            
            [obj enumerateObjectsUsingBlock:^(DataPointSeg * _Nonnull objdata, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *data=[NSArray arrayWithArray:[MPMessagePackReader readData:objdata.value error:nil]];
                NSNumber *sincetime=data[1];
                NSDate *date=[[NSDate alloc]initWithTimeIntervalSince1970:sincetime.longValue];
                NSTimeZone *zone = [NSTimeZone systemTimeZone]; // 获得系统的时区
                NSTimeInterval time = [zone secondsFromGMTForDate:date];// 以秒为单位返回当前时间与系统格林尼治时间的差
                NSDate *dateNow = [date dateByAddingTimeInterval:-2*time];
                NSArray *singleHistory=@[data[0],dateNow,data[2]];
                [historyList addObject:singleHistory];
                NSLog(@"是否已接听:%@ 处理时间%@ 持续时间:%@",data[0],date,data[2]);
            }];
            NSLog(@"idDataList:%@ count:%zd",idDataList,obj.count);
        }
        if (success) {
            success(historyList);
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        if (fail) {
            fail(type);
        }
    }];
}


+(void)getVideoWifiInfoWithCid:(NSString *)cid
                       success:(void(^)(NSString *wifiSSID))success
                       failure:(void (^)(NSInteger type))fail
{
    DataPointIDVerSeg *seg1 = [[DataPointIDVerSeg alloc]init];
    seg1.msgId = 201;//获取WiFi ssid
    seg1.version = 1;
    [[JFGSDKDataPoint sharedClient]robotGetDataWithPeer:cid msgIds:@[seg1] asc:YES limit:100 success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        if (idDataList.count>0) {
            
            NSArray *obj=[NSArray arrayWithArray:idDataList[0]];
            if (obj.count>0) {
                DataPointSeg *dp=obj[0];
                NSArray *wifiData=[NSArray arrayWithArray:[MPMessagePackReader readData:dp.value error:nil]];
                
                if (success) {
                    success(wifiData[1]);
                }
            }
            else
            {
                if (success) {
                    success(@"加载失败");
                }
            }
        }
    } failure:^(RobotDataRequestErrorType type) {
        if (fail) {
            fail(type);
        }
    }];
}


@end
