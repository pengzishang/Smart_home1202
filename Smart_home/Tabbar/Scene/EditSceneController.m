//
//  EditSceneController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/9/13.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "EditSceneController.h"
#import "SceneCellCommon.h"
#import "TTSCoreDataManager.h"
#import "FTPopOverMenu.h"
#import "TTSUtility.h"
@interface EditSceneController ()<SceneCellDelegata>

@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectView;
@property (strong,nonatomic)NSArray <DeviceForScene *>*deviceOfScene;


@end

@implementation EditSceneController

-(NSArray<DeviceForScene *> *)deviceOfScene
{
    if (!_deviceOfScene) {
        NSSortDescriptor *sortbyDate=[[NSSortDescriptor alloc]initWithKey:@"deviceCustomName" ascending:YES];
        _deviceOfScene=[self.sceneInfo.devicesInfo sortedArrayUsingDescriptors:@[sortbyDate]];
    }
    return _deviceOfScene;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.mainCollectView reloadData];
}

-(void)loadData
{
    
}
- (IBAction)rightBtn:(UIBarButtonItem *)sender event:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:^{
           [TTSUtility deleteScene:self.sceneInfo room:self.roomInfo];
    }];
}

- (IBAction)didSelectBtn:(UIButton *)sender {
    
    
}

#pragma mark sceneCell

-(void)didClickSceneBtnTag:(NSUInteger)tag index:(NSIndexPath *)index
{
    NSInteger beforeStatus=self.deviceOfScene[index.row].deviceSceneStatus.integerValue;
    NSUInteger deviceType=self.deviceOfScene[index.row].deviceType.integerValue;
    NSUInteger btnTag=tag-1000;
    if (btnTag==4) {
        beforeStatus-4>=0?(beforeStatus-=4):(beforeStatus+=4);
    }
    else if (btnTag==2){
        beforeStatus%4-2>=0?(beforeStatus-=2):(beforeStatus+=2);
    }
    else if (btnTag==1){
        if (deviceType==4||deviceType==5) {
            beforeStatus==2?(beforeStatus=1):(beforeStatus=2);
        }
        else{
            beforeStatus%2-1>=0?(beforeStatus-=1):(beforeStatus+=1);
        }
    }
    self.deviceOfScene[index.row].deviceSceneStatus=@(beforeStatus).stringValue;
    [[TTSCoreDataManager getInstance]updateData];
    [_mainCollectView reloadItemsAtIndexPaths:@[index]];
}

#pragma mark-collectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.deviceOfScene.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cellId=@[@"socketCell",@"oneCell",@"twoCell",@"threeCell",@"curtainCell",@"curtainCell"];
    DeviceForScene *device=self.deviceOfScene[indexPath.row];
    NSUInteger deviceType=device.deviceType.integerValue;
    NSUInteger deviceStatus=device.deviceSceneStatus.integerValue;
    SceneCellCommon *cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellId[deviceType] forIndexPath:indexPath];
    cell.delegate=self;
    cell.nameLab.text=device.deviceCustomName;
    [cell setImageWithStatus:deviceStatus deviceType:deviceType index:indexPath];
    return cell;
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
    NSUInteger high=width*1.3;
    return CGSizeMake(width, high);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
