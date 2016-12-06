//
//  EditSceneController.h
//  Smart_home
//
//  Created by 彭子上 on 2016/9/13.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditSceneController : UIViewController

@property (nonatomic,strong)NSMutableArray *devices;
@property (nonatomic,strong)RoomInfo *roomInfo;
@property (nonatomic,strong)SceneInfo *sceneInfo;

@end
