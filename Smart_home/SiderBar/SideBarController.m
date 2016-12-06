//
//  SideBarController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/6/29.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "SideBarController.h"

@interface SideBarController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *SideBarItems;

@end

@implementation SideBarController


- (void)viewDidLoad {
    [super viewDidLoad];
    _SideBarItems.tableFooterView=[[UIView alloc]init];
    UIImageView *siderBackground=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"left_sidebar_bg"]];
    siderBackground.layer.opacity=0.8;
    self.SideBarItems.backgroundView=siderBackground;
}

- (IBAction)didClickLogin:(UITapGestureRecognizer *)sender {
    if (_delegate&&[_delegate respondsToSelector:@selector(didClickLogin)]) {
        [_delegate didClickLogin];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *imageName=@[@"left_sidebar_video_monitoring_icon",@"left_sidebar_space_icon",@"left_sidebar_remote_control_icon",@"left_sidebar_infrared_control_icon",@"left_sidebar_setting_icon",@"left_sidebar_video_monitoring_icon"];
    NSArray *labTitle=@[@"视频监控",@"一键添加设备",@"远程控制器",@"红外控制器",@"设置",@"消息"];
    SiderNormalCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SiderNormal"];
    cell.SiderNormalLab.text=labTitle[indexPath.row];
    cell.SiderNormalImage.image=[UIImage imageNamed:imageName[indexPath.row]];
    if (indexPath.row==0&&indexPath.row==1) {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(didClickTableItem:)]&&_delegate) {
        [_delegate didClickTableItem:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
