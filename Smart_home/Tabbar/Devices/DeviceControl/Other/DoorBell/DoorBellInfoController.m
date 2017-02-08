//
//  DoorBellInfoController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/10/31.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "DoorBellInfoController.h"
#import "DoorCheckController.h"
#import "TTSUtility.h"

@interface DoorBellInfoController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;
@property (strong,nonatomic)NSMutableArray <NSArray *>*historyList;
@property (strong,nonatomic)NSMutableDictionary<NSString *,NSMutableArray *> *sectionTitleAndTime;
@property (weak, nonatomic) IBOutlet UITableView *historyTableList;

@end

@implementation DoorBellInfoController

-(NSMutableArray<NSArray *> *)historyList
{
    if (!_historyList) {
        _historyList=[NSMutableArray array];
    }
    return _historyList;
}

-(NSMutableDictionary<NSString *,NSMutableArray *> *)sectionTitleAndTime
{
    if (!_sectionTitleAndTime) {
        _sectionTitleAndTime=[NSMutableDictionary dictionary];
    }
    return _sectionTitleAndTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _navTitle.title=self.targetDevice.alias;
    [self refreshData];
    // Do any additional setup after loading the view.
}
- (IBAction)goCheck:(UIButton *)sender {
    [self performSegueWithIdentifier:@"info2check" sender:self.targetDevice];
}

-(void)refreshData
{
    _historyList=nil;
    _sectionTitleAndTime=nil;
    [TTSUtility getVideoHistoryListWithCid:self.targetDevice.uuid success:^(NSArray *historyList) {
        self.historyList=[NSMutableArray arrayWithArray:historyList];
        [self.historyList enumerateObjectsUsingBlock:^(NSArray * _Nonnull historyListObj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *dayTitle= [NSString translateDateToDay:historyListObj[1]];
            __block BOOL isContain=NO;
            [self.sectionTitleAndTime enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray * _Nonnull obj, BOOL * _Nonnull stop) {
                if ([key isEqualToString:dayTitle]) {
                    isContain=YES;
                    [obj addObject:historyListObj];
                    *stop=YES;
                }
            }];
            if (!isContain) {
                self.sectionTitleAndTime[dayTitle]=@[historyListObj].mutableCopy;
            }
        }];
        NSLogMethodArgs(@"%@",_sectionTitleAndTime);
        
        [self.historyTableList reloadData];
    } failure:^(NSInteger type) {
        NSLogMethodArgs(@"%zd",type);
    }];
}

#pragma mark JFGSDK Delegate


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionTitleAndTime allKeys].count;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionTitleAndTime allKeys][section];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key=[self.sectionTitleAndTime allKeys][section];
    return self.sectionTitleAndTime[key].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key= [self.sectionTitleAndTime allKeys][indexPath.section];
    NSArray *dataArr=[NSArray arrayWithArray: self.sectionTitleAndTime[key]];
    NSString *time=[NSString translateDateToTime:dataArr[indexPath.row][1]] ;
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    UILabel *lable1=[cell viewWithTag:1001];
    lable1.text=[NSString stringWithFormat:@"接听时间:%@",time];
    UILabel *lable2=[cell viewWithTag:1002];
    lable2.text=[NSString stringWithFormat:@"持续时间:%@",self.historyList[indexPath.row][2]];
    return cell;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"info2check"]) {
        DoorCheckController *target=segue.destinationViewController;
        target.targetDevice=sender;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
