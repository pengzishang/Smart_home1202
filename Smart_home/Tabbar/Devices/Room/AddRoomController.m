//
//  AddRoomController.m
//  Smart_home
//
//  Created by 彭子上 on 2016/8/29.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "AddRoomController.h"
#import "DevicesController.h"
//#import "TTSCoreDataManager.h"
#import "TTSUtility.h"
@interface AddRoomController ()
{
    NSUInteger _currentRoomType;
}
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectView;
@property (weak, nonatomic) IBOutlet UIImageView *roomImage;
@property (weak, nonatomic) IBOutlet UITextField *roomField;

@end

@implementation AddRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    _roomImage.layer.cornerRadius=5.0;
    _roomImage.layer.borderWidth=3.0;
    _roomImage.layer.borderColor=(__bridge CGColorRef _Nullable)([UIColor blackColor]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"(dd日HH:mm)"];
    _roomField.placeholder=[NSString stringWithFormat:@"浴室:%@",[dateFormatter stringFromDate:[NSDate date]]];
    // Do any additional setup after loading the view.
}


- (IBAction)cancle:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)confirm:(UIBarButtonItem *)sender {
    if (_roomField.text.length==0&&_roomField.placeholder.length==0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"房间名不能为空" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        RoomInfo *roominfo= [TTSUtility addRoomWithName:_roomField.text.length==0?_roomField.placeholder:_roomField.text roomType:@(_currentRoomType)];
        [self performSegueWithIdentifier:@"addRoom2Main" sender:roominfo];
    }

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cellImage=@[@"room_bathroom_room",@"room_bedroom_room",@"room_kitchen_room",@"room_livingroom_room",@"room_book_room",@"room_children_room",@"room_dinner_room",@"room_custom_room"];
    NSArray *cellTitle=@[@"浴室",@"卧室",@"厨房",@"客厅",@"书房",@"儿童房",@"餐厅",@"自定义"];
    UICollectionViewCell *roomTypeCell=[_mainCollectView dequeueReusableCellWithReuseIdentifier:@"roomTypeCell" forIndexPath:indexPath];
    roomTypeCell.tag=indexPath.row+2000;
    roomTypeCell.layer.cornerRadius=5.0;
    UIImageView *cellIcon=[roomTypeCell viewWithTag:1001];
    cellIcon.layer.cornerRadius=5.0;
    UILabel *cellLab=[roomTypeCell viewWithTag:1002];
    cellIcon.image=[UIImage imageNamed:cellImage[indexPath.row]];
    cellLab.text=cellTitle[indexPath.row];
    return roomTypeCell;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger width=(Screen_Width-40)/3;
    NSUInteger high=width;
    return CGSizeMake(width, high);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}


//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _currentRoomType=indexPath.row;
    NSArray *cellImage=@[@"room_bathroom_room",@"room_bedroom_room",@"room_kitchen_room",@"room_livingroom_room",@"room_book_room",@"room_children_room",@"room_dinner_room",@"room_custom_room"];
    NSArray *cellTitle=@[@"浴室",@"卧室",@"厨房",@"客厅",@"书房",@"儿童房",@"餐厅",@"自定义"];
    _roomImage.image=[UIImage imageNamed:cellImage[indexPath.row]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"(dd日HH:mm)"];
    _roomField.placeholder=[NSString stringWithFormat:@"%@:%@",cellTitle[indexPath.row],[dateFormatter stringFromDate:[NSDate date]]];
    NSArray *visibleCells=[collectionView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(UICollectionViewCell *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *cellLab=[obj viewWithTag:1002];
        cellLab.backgroundColor=[UIColor grayColor];
    }];
    UICollectionViewCell *cell=[self.view viewWithTag:indexPath.row+2000];
    UILabel *cellLab=[cell viewWithTag:1002];
    cellLab.backgroundColor=[UIColor blackColor];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addRoom2Main"]) {
        DevicesController *target=segue.destinationViewController;
        target.currentRoom=(RoomInfo *)sender;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
