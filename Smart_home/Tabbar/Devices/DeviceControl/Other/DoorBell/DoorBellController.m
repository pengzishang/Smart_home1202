//
//  DoorBellController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/10/11.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "DoorBellController.h"
#import "DoorBellBinding.h"
#import "DoorBellInfoController.h"
#import "EditBellController.h"
#import "MJRefresh.h"
#import <JFGSDK/JFGSDKVideoView.h>
#import <JFGSDK/JFGSDKDataPoint.h>

@interface DoorBellController ()<JFGSDKCallbackDelegate,JFGSDKPlayVideoDelegate>
{
//    JFGSDKVideoView *playView;
//    JFGSDKDataPoint *dataPoint;
}
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong,nonatomic)NSMutableArray *deviceList;

@end

@implementation DoorBellController

-(NSMutableArray *)deviceList
{
    if (!_deviceList) {
        _deviceList=[NSMutableArray array];
    }
    return _deviceList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [JFGSDK addDelegate:self];
    
    //playView = [[JFGSDKVideoView alloc]init];
    //    playView.center = CGPointMake(self.view.bounds.size.width*0.5, 64+300);
    //playView.delegate = self;
    //    [self.view addSubview:playView];
    //    [playView getHistoryVideoList:@"500000005083"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MJRefreshGifHeader *header=[MJRefreshGifHeader headerWithRefreshingBlock:^{
        [JFGSDK refreshDeviceList];
    }];
    self.mainTableView.mj_header=header;
    [header setTitle:@"放开以刷新设备" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新设备中...." forState:MJRefreshStateRefreshing];
    [header beginRefreshing];
}


-(void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    NSLog(@"mac:%@  ver:%@ address:%@ cid:%@",ask.mac,ask.ver,ask.address,ask.cid);
}
//已绑定设备列表
-(void)jfgDeviceList:(NSArray<JFGSDKDevice *> *)deviceList
{
    //登陆成功，跳转设备列表页面
    [self.mainTableView.mj_header endRefreshingWithCompletionBlock:^{
        _deviceList = [NSMutableArray arrayWithArray:deviceList];
        [self.mainTableView reloadData];
    }];
}

#pragma mark JFGSDK Delegate

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addBell:(UIBarButtonItem *)sender {
        [self performSegueWithIdentifier:@"bell2add" sender:nil];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"doorBellCell" forIndexPath:indexPath];
    JFGSDKDevice *device=self.deviceList[indexPath.row];
    UILabel *uuid=[cell viewWithTag:1002];
    uuid.text=device.uuid;
    UILabel *alise=[cell viewWithTag:1001];
    alise.text=device.alias;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"doorBell2deviceInfo" sender:self.deviceList[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *delete=[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        JFGSDKDevice *device=self.deviceList[indexPath.row];
        [JFGSDK unBindDev:device.uuid];
        [self.deviceList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    delete.backgroundColor=[UIColor redColor];
    UITableViewRowAction *edit=[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"编辑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self performSegueWithIdentifier:@"doorBellEdit" sender:self.deviceList[indexPath.row]];
    }];
    edit.backgroundColor=[UIColor blueColor];
    return @[delete,edit];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(JFGSDKDevice *)sender {
    if ([segue.identifier isEqualToString:@"doorBell2deviceInfo"]) {
        DoorBellInfoController *target=segue.destinationViewController;
        target.targetDevice=sender;
    }
    else if ([segue.identifier isEqualToString:@"doorBellEdit"]){
        EditBellController *target=segue.destinationViewController;
        target.device=sender;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


-(IBAction)unwindToMainVideoList:(UIStoryboardSegue *)sender
{
    if ([sender.sourceViewController isKindOfClass:[DoorBellBinding class]]) {
        
    }
    else if ([sender.sourceViewController isKindOfClass:[EditBellController class]]) {
        
        [JFGSDK setAlias:self.editName forCid:self.editDevice.uuid];
        
    }
}
@end
