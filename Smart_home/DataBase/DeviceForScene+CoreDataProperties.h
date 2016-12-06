//
//  DeviceForScene+CoreDataProperties.h
//  Smart_home
//
//  Created by 彭子上 on 2016/9/5.
//  Copyright © 2016年 彭子上. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DeviceForScene.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceForScene (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *deviceCustomName;
@property (nullable, nonatomic, retain) NSString *deviceInfaredCode;
@property (nullable, nonatomic, retain) NSString *deviceMacID;
@property (nullable, nonatomic, retain) NSString *deviceSceneStatus;
@property (nullable, nonatomic, retain) NSNumber *deviceType;
@property (nullable, nonatomic, retain) SceneInfo *sceneInfo;

@end

NS_ASSUME_NONNULL_END
