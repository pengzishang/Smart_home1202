//
//  SceneInfo+CoreDataProperties.h
//  Smart_home
//
//  Created by 彭子上 on 2016/9/5.
//  Copyright © 2016年 彭子上. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SceneInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface SceneInfo (CoreDataProperties)

@property(nullable, nonatomic, retain) NSDate *sceneCreateDate;
@property(nullable, nonatomic, retain) NSNumber *sceneID;
@property(nullable, nonatomic, retain) NSString *sceneName;
@property(nullable, nonatomic, retain) NSNumber *sceneTapCount;
@property(nullable, nonatomic, retain) NSNumber *sceneType;
@property(nullable, nonatomic, retain) NSSet<DeviceForScene *> *devicesInfo;
@property(nullable, nonatomic, retain) RoomInfo *roomInfo;

@end

@interface SceneInfo (CoreDataGeneratedAccessors)

- (void)addDevicesInfoObject:(DeviceForScene *)value;

- (void)removeDevicesInfoObject:(DeviceForScene *)value;

- (void)addDevicesInfo:(NSSet<DeviceForScene *> *)values;

- (void)removeDevicesInfo:(NSSet<DeviceForScene *> *)values;

@end

NS_ASSUME_NONNULL_END
