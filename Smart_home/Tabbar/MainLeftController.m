//
//  MainLeftController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/6/29.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "MainLeftController.h"
#import "LaunchView.h"
#import "TTSUtility.h"
#import "SideBarController.h"
#import "SettingController.h"
#import "DevicesController.h"
#import "PopTopView.h"
#import "HyPopMenuView.h"
#import "AppDelegate.h"

@interface MainLeftController () <SiderBarDelegate, DeviceDelegate, SettingBarDelegate, HyPopMenuViewDelegate, JFGSDKCallbackDelegate> {
    AppDelegate *app;
    BOOL onBackGroundLoad;//用来后台推送的时候的的锁
    BOOL onRuningLoad;//用前台推送的锁
}
@property(nonatomic, strong) HyPopMenuView *menu;
@property(nonatomic, strong) RoomInfo *roomInfo;

@end

@implementation MainLeftController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.isLeftOpen = NO;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SideBarController *sideBar = [storyboard instantiateViewControllerWithIdentifier:@"left"];
        sideBar.delegate = self;
        self.leftDrawerViewController = sideBar;
        [self setMaximumLeftDrawerWidth:200 animated:YES completion:^(BOOL finished) {

        }];

        SettingController *setting = [storyboard instantiateViewControllerWithIdentifier:@"right"];
        setting.delegate = self;
        self.rightDrawerViewController = setting;
        [self setMaximumRightDrawerWidth:200 animated:YES completion:^(BOOL finished) {

        }];

        [self setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeCustom];
        [self setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];

        UITabBarController *center = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
        DevicesController *mainDeviceView = center.childViewControllers[0].childViewControllers[0];
        mainDeviceView.delegate = self;
        self.centerViewController = center;

        [self setShouldStretchDrawer:YES];
        [self setShowsShadow:YES];
        self.shadowOpacity = 0.4;

        [self setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeFull];

        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        path = [path stringByAppendingPathComponent:@"jfgworkdic"];
        [JFGSDK connectForWorkDir:path];
        [JFGSDK addDelegate:self];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [app addObserver:self forKeyPath:@"pushUserInfo" options:NSKeyValueObservingOptionNew context:nil];
    _menu = [HyPopMenuView sharedPopMenuManager];

    if (self.centerViewController) {
        CGFloat currentVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
        CGFloat versionInStore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"VersionInStore"] floatValue];
        if (currentVersion != versionInStore) {
            [self needAddAllRoom];//如果没用所有房间信息,那么需要插入

            LaunchView *launView = [[LaunchView alloc] initWithFrame:[UIScreen mainScreen].bounds images:@[@"Launch1", @"Launch2", @"Launch3"] complete:^{
                [[NSUserDefaults standardUserDefaults] setObject:@(currentVersion) forKey:@"VersionInStore"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstTime"] integerValue] == 0) {
//                    [self firstTimeAlert];
                }
            }];
            [self.view addSubview:launView];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLogMethodArgs(@"didappear");
    if (onBackGroundLoad) {
        [self performSegueWithIdentifier:@"getcalling" sender:nil];
        onBackGroundLoad = NO;
    }

}

//观察推送
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"pushUserInfo"]) {
        onBackGroundLoad = YES;
        NSDictionary *userinfo = change[@"new"][@"aps"];
        JFGSDKDoorBellCall *new = [JFGSDKDoorBellCall new];
        new.cid = [userinfo[@"custom"] substringWithRange:NSMakeRange(7, 12)];
        if (onRuningLoad) {
            [self performSegueWithIdentifier:@"getcalling" sender:new];
            onBackGroundLoad = NO;
        }
        onRuningLoad = YES;
    }
}

- (void)needAddAllRoom {
    __block BOOL isNeedAdd = YES;
    NSMutableArray <RoomInfo *> *roomInfos = [NSMutableArray arrayWithArray:[[TTSCoreDataManager getInstance] getResultArrWithEntityName:@"RoomInfo" predicate:nil]];
    [roomInfos enumerateObjectsUsingBlock:^(RoomInfo *_Nonnull roomObj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([roomObj.roomType isEqualToNumber:@(10)]) {
            isNeedAdd = NO;
            *stop = YES;
        }
    }];
    if (isNeedAdd) {
        [TTSUtility addRoomWithName:@"所有空间设备" roomType:@10];
    }
}

- (void)firstTimeAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"建议" message:@"检测到您是第一次运行本软件,点击确定添加附近所有设备" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmlAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *_Nonnull action) {
        [TTSUtility addMutiDeviceAnimationFinish:^{
            if (_delegate && [_delegate respondsToSelector:@selector(didFinishAdding)]) {
                [_delegate didFinishAdding];
            }
        }];
    }];

    [alertController addAction:confirmlAction];
    [self presentViewController:alertController animated:YES completion:nil];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)turnToWebCam {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tocu://"]];
    // 判断当前系统是否有安装客户端
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        // 如果已经安装客户端，就使用客户端打开链接
        [[UIApplication sharedApplication] openURL:url];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/2cu/id680995913?mt=8"]];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark 可视对讲代理

- (void)jfgDoorbellCall:(JFGSDKDoorBellCall *)call {
    //    [TTSUtility openVideo:call];
    [self performSegueWithIdentifier:@"getcalling" sender:call];
}

#pragma mark SiderBarDelegate

- (void)didClickTableItem:(NSUInteger)index {
    [self closeDrawerAnimated:YES completion:^(BOOL finished) {

        if (index == 2) {
            [self performSegueWithIdentifier:@"remoteBinding" sender:nil];
        } else if (index == 3) {
            [self performSegueWithIdentifier:@"infraredBinding" sender:nil];
        } else if (index == 4) {
            [self openDrawerSide:MMDrawerSideRight animated:YES completion:^(BOOL finished) {

            }];
        } else if (index == 1) {
            [TTSUtility addMutiDeviceAnimationFinish:^{
                if (_delegate && [_delegate respondsToSelector:@selector(didFinishAdding)]) {
                    [_delegate didFinishAdding];
                }
            }];

        } else if (index == 0) {
            [self turnToWebCam];
        }
    }];
}

- (void)didClickLogin {
    _isLeftOpen = NO;
    _isLeftOpen ? [self openDrawerSide:MMDrawerSideLeft animated:YES completion:nil] : [self closeDrawerAnimated:YES completion:^(BOOL finished) {
        [self performSegueWithIdentifier:@"login" sender:nil];
    }];

}

#pragma mark DeviceMainDelegate

- (void)didClickLeftDrawer {

    _isLeftOpen = !_isLeftOpen;
    _isLeftOpen ? [self openDrawerSide:MMDrawerSideLeft animated:YES completion:nil] : [self closeDrawerAnimated:YES completion:nil];

}

- (void)didClickSceneIcon:(RoomInfo *)roomInfo {
    [self sceneMenu:roomInfo];
    _menu.backgroundType = HyPopMenuViewBackgroundTypeLightBlur;
    [_menu openMenu];
}

#pragma mark Setting

- (void)didClickSettingTableItem:(NSUInteger)index {
    [self closeDrawerAnimated:YES completion:^(BOOL finished) {
        switch (index) {
            case 0: {
                [self cleanAppData];
            }
                break;
            case 1: {

            }
                break;
            case 2: {

            }
                break;
            case 3: {
                [self performSegueWithIdentifier:@"remoteSetting" sender:nil];
                //加入远程设置
            }
                break;
            default:
                break;
        }
    }];
}

- (void)didClickRemoteSwitch:(UISwitch *)remoteSwitch {
    [self closeDrawerAnimated:YES completion:^(BOOL finished) {
        if (remoteSwitch.isOn) {
            if (!RemoteDefault) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"没有绑定远程控制器,\n点击[取消]关闭远程控制\n点击[确定]绑定一个远程控制器" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"RemoteOn"];
                    [remoteSwitch setOn:NO];
                }];
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                    [self performSegueWithIdentifier:@"remoteBinding" sender:nil];
                }];

                [alertController addAction:cancelAction];
                [alertController addAction:confirmAction];
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RemoteOn"];
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"RemoteOn"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sceneMenu:(RoomInfo *)roomInfo {
    NSArray *sceneIcon = @[@"scene_icon_alloff", @"scene_icon_allon", @"scene_icon_custom", @"scene_icon_home", @"scene_icon_leaving", @"scene_icon_meeting", @"scene_icon_night", @"scene_icon_reading", @"scene_icon_tving", @"scene_icon_add"];
    NSArray <SceneInfo *> *allScene = [TTSUtility initScene:roomInfo];
    NSMutableArray *allModel = [NSMutableArray array];
    [allScene enumerateObjectsUsingBlock:^(SceneInfo *_Nonnull sceneObj, NSUInteger idx, BOOL *_Nonnull stop) {
        PopMenuModel *model = [PopMenuModel
                allocPopMenuModelWithImageNameString:sceneIcon[sceneObj.sceneType.integerValue]
                                       AtTitleString:sceneObj.sceneName
                                         AtTextColor:[UIColor grayColor]
                                    AtTransitionType:PopMenuTransitionTypeCustomizeApi
                          AtTransitionRenderingColor:nil];
        [allModel addObject:model];
    }];
    PopMenuModel *model = [PopMenuModel
            allocPopMenuModelWithImageNameString:sceneIcon[sceneIcon.count - 1]
                                   AtTitleString:@"添加情景"
                                     AtTextColor:[UIColor grayColor]
                                AtTransitionType:PopMenuTransitionTypeCustomizeApi
                      AtTransitionRenderingColor:nil];
    [allModel addObject:model];

    _menu.dataSource = allModel;
    _menu.delegate = self;
    _menu.popMenuSpeed = 12.0f;
    _menu.automaticIdentificationColor = false;
    _menu.animationType = HyPopMenuViewAnimationTypeViscous;

    PopTopView *topView = [PopTopView popTopViewInit];
    topView.frame = CGRectMake(0, 14, CGRectGetWidth(self.view.frame), 92);
    _menu.topView = topView;

}

#pragma HyPopMenuView //这里结构有点乱,原因是因为插件的代理方法指向这里,而非DeviceControl

- (void)popMenuView:(HyPopMenuView *)popMenuView didSelectItemAtIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickSceneIndex:)]) {
        [_delegate didClickSceneIndex:index];
    }
}

- (void)popMenuView:(HyPopMenuView *)popMenuView didLongSelectItemAtIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(willEditSceneIndex:)]) {
        [_delegate willEditSceneIndex:index];
    }
}


- (void)cleanAppData {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Opeartion Comfirm", @"操作确认") message:NSLocalizedString(@"Are you sure delete all Data", @"真的要删除所有数据吗?") preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *OK = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *_Nonnull action) {
        [TTSUtility showForShortTime:2 mainTitle:NSLocalizedString(@"ClearComplete", @"清除完毕") subTitle:NSLocalizedString(@"All Data Clear!", @"全部数据清理完毕")];
        NSArray *rooms = [[TTSCoreDataManager getInstance] getResultArrWithEntityName:@"RoomInfo" predicate:nil];
        for (RoomInfo *room in rooms) {
            [[TTSCoreDataManager getInstance] deleteDataWithObject:room];
        }

        NSArray *devices = [[TTSCoreDataManager getInstance] getResultArrWithEntityName:@"DeviceInfo" predicate:nil];
        for (DeviceInfo *device in devices) {
            [[TTSCoreDataManager getInstance] deleteDataWithObject:device];
        }

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"InfraredControlID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"RemoteControlID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"RemoteOn"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VersionInStore"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FirstTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [TTSUtility addRoomWithName:@"所有空间设备" roomType:@10];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
    [actionSheet addAction:OK];
    [actionSheet addAction:cancel];
    [self presentViewController:actionSheet animated:NO completion:nil];

}

- (void)dealloc {
    [app removeObserver:self forKeyPath:@"pushUserInfo" context:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"getcalling"]) {
        CallingController *target = segue.destinationViewController;
//         JFGSDKDoorBellCall *device=[JFGSDKDoorBellCall new];
        target.userInfo = sender;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
