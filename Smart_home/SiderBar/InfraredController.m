//
//  InfraredController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/7/6.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "InfraredController.h"
#import "BluetoothManager.h"
#import "AppDelegate.h"
@interface InfraredController ()
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UILabel *currentInfraredController;

@property (strong,nonatomic)NSMutableArray <__kindof NSDictionary *> *nearRemoteController;
@property (assign,nonatomic)NSUInteger indexIdx;
@property (assign,nonatomic)NSUInteger selectIdx;
@end

@implementation InfraredController

-(NSMutableArray *)nearRemoteController
{
    if (!_nearRemoteController) {
        _nearRemoteController=[NSMutableArray array];
    }
    return _nearRemoteController;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _indexIdx=0;
    _selectIdx=0;
    AppDelegate *app=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app.autoScan invalidate];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"InfraredControlID"]) {
        _currentInfraredController.text=[NSString stringWithFormat:@"当前红外伴侣:%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"InfraredControlID"]];
    }
    _mainTableView.tableFooterView=[[UIView alloc]init];
    [self performSelector:@selector(refreshControl:) withObject:nil afterDelay:1.0];
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AppDelegate *app=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    app.autoScan=[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(autoScan:) userInfo:nil repeats:YES];
    [app.autoScan fire];
}


-(void)autoScan:(id)sender
{
    NSLogMethodArgs(@"autoScan");
    [[BluetoothManager getInstance]scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
}

- (IBAction)refreshControl:(UIBarButtonItem *)sender {
    [[BluetoothManager getInstance]scanPeriherals:YES AllowPrefix:@[@(ScanTypeInfraredControl)]];
    [BluetoothManager getInstance].detectDevice=^(NSDictionary *infoDic){
        [self addRemote:infoDic];
    };
}

-(void)addRemote:(NSDictionary *)infoDic
{
    NSString *deviceName = infoDic[AdvertisementData][@"kCBAdvDataLocalName"];
    NSLogMethodArgs(@"%@",deviceName);
    if (![self isContainID:deviceName]) {
        [_nearRemoteController addObject:infoDic];
        [_mainTableView reloadData];
    }
    else
    {
        static NSUInteger times=0;
        if (++times==20) {
            [_nearRemoteController replaceObjectAtIndex:_indexIdx withObject:infoDic];
            [_mainTableView reloadData];
            times=0;
        }
    }
}

-(BOOL)isContainID:(NSString *)deviceName
{
    __block BOOL isContain=NO;
    [_nearRemoteController enumerateObjectsUsingBlock:^(__kindof NSDictionary * _Nonnull storeInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *storeID=storeInfo[AdvertisementData][@"kCBAdvDataLocalName"];
        if ([storeID isEqualToString:deviceName]) {
            isContain=YES;
            _indexIdx=idx;
            *stop=YES;
        }
    }];
    return isContain;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.nearRemoteController.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *infoDic=_nearRemoteController[indexPath.row];
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"infaredCell" forIndexPath:indexPath];
    UILabel *deviceIDLab=[cell viewWithTag:1001];
    UILabel *rssiLab=[cell viewWithTag:1002];
    UIImageView *imageView=[cell viewWithTag:1000];
    if (indexPath.row==_selectIdx) {
        imageView.image=[UIImage imageNamed:@"pressed_select_btn"];
    }
    else
    {
        imageView.image=[UIImage imageNamed:@"default_unselect_btn"];
    }
    
    deviceIDLab.text=infoDic[AdvertisementData][@"kCBAdvDataLocalName"];
    rssiLab.text=[NSString stringWithFormat:@"信号强度:%@",infoDic[RSSI_VALUE]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectIdx=indexPath.row;
    NSString *remoteID=[_nearRemoteController[indexPath.row][AdvertisementData][@"kCBAdvDataLocalName"] substringFromIndex:7];
    
    _currentInfraredController.text=[NSString stringWithFormat:@"目前的默认红外伴侣为:%@",remoteID];
    [[NSUserDefaults standardUserDefaults]setObject:remoteID forKey:@"InfraredControlID"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}


- (IBAction)didClickDone:(id)sender {
    [[BluetoothManager getInstance]scanPeriherals:NO AllowPrefix:@[@(ScanTypeAll)]];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
