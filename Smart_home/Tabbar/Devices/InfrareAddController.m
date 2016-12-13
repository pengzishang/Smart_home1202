//
//  InfrareAddController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/5.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "InfrareAddController.h"
#import "ChooseBrandController.h"

@interface InfrareAddController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectView;
@end

@implementation InfrareAddController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_mainCollectView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"InfraredControlID"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"没有绑定红外伴侣将不能正常使用此功能,点击确定来绑定红外伴侣" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"infrareNoneBack" sender:nil];
            
        }];
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"add2infrared" sender:nil];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:addAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark-collectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cellImage=@[@"add_air",@"add_tv",@"add_dvd",@"add_amp",@"add_box"];
    NSArray *cellTitle=@[@"空调",@"电视",@"DVD",@"功放机",@"机顶盒"];
    UICollectionViewCell *infraredCell=[_mainCollectView dequeueReusableCellWithReuseIdentifier:@"infraredCell" forIndexPath:indexPath];
    infraredCell.layer.cornerRadius=5.0;
    UIImageView *cellIcon=[infraredCell viewWithTag:1001];
    UILabel *cellLab=[infraredCell viewWithTag:1002];
    cellIcon.image=[UIImage imageNamed:cellImage[indexPath.row]];
    cellLab.text=cellTitle[indexPath.row];
    return infraredCell;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}




//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger width=(Screen_Width-10-10-10)/2;
    NSUInteger high=width+20;
    return CGSizeMake(width, high);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"chooseBrand" sender:indexPath];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)sender {
    if ([segue.identifier isEqualToString:@"chooseBrand"]) {
        ChooseBrandController *target=[[ChooseBrandController alloc]init];
        target=segue.destinationViewController;
        target.deviceType=(InfrareDeviceType )sender.row;
        NSString *path=[[NSBundle mainBundle]pathForResource:@"InfraredBrandList" ofType:@"plist"];
        NSDictionary *infraredList=[[NSDictionary alloc]initWithContentsOfFile:path];
        NSArray *deviceTitle=@[@"AIR",@"TV",@"DVD",@"AMP",@"BOX"];
        target.resourseArr=infraredList[deviceTitle[sender.row]];
    }
}


@end
