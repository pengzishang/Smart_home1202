//
//  SettingController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/12.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "SettingController.h"

@interface SettingController ()
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainTableView.tableFooterView=[[UIView alloc]init];
    UIImageView *siderBackground=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"left_sidebar_bg"]];
    self.mainTableView.backgroundView=siderBackground;    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [_mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)remoteValueChange:(UISwitch *)sender {
    if (_delegate&&[_delegate respondsToSelector:@selector(didClickRemoteSwitch:)]) {
        [_delegate didClickRemoteSwitch:sender];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    else if (section==1)
    {
        return 3;
    }
    else
    {
        return 0;
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (section==0) {
        return @"远程相关";
    }
    else if (section==1)
    {
        return @"系统设置";
    }
    else
    {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"isRemote"];
        UISwitch *remoteSwitch=[cell viewWithTag:1001];
        NSNumber *isOn=[[NSUserDefaults standardUserDefaults]objectForKey:@"RemoteOn"];
        [remoteSwitch setOn:isOn.boolValue];
        cell.backgroundColor=[UIColor clearColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.section==1)
    {
        NSArray *imageName=@[@"setting_clean",@"setting_version",@"setting_switch",@""];
        NSArray *labTitle=@[@"清理应用数据",[NSString stringWithFormat:@"版本号:%f",[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue]],@"切换中英文"];
        
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"systemCell"];
        cell.backgroundColor=[UIColor clearColor];
        UILabel *cellTitle=[cell viewWithTag:2002];
        cellTitle.text=labTitle[indexPath.row];
        UIImageView *cellIcon=[cell viewWithTag:2001];
        cellIcon.image=[UIImage imageNamed:imageName[indexPath.row]];
        return cell;
    }
    else
    {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"none"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        if (_delegate&&[_delegate respondsToSelector:@selector(didClickSettingTableItem:)]) {
            [_delegate didClickSettingTableItem:indexPath.row];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
