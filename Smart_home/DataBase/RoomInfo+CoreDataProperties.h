//
//  RoomInfo+CoreDataProperties.h
//  Smart_home
//
//  Created by 彭子上 on 2016/9/5.
//  Copyright © 2016年 彭子上. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "RoomInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface RoomInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *isCommonRoom;
@property (nullable, nonatomic, retain) NSDate *roomCreateDate;
@property (nullable, nonatomic, retain) NSNumber *roomID;
@property (nullable, nonatomic, retain) NSString *roomName;
@property (nullable, nonatomic, retain) NSString *roomRemoteID;
@property (nullable, nonatomic, retain) NSNumber *roomTapCount;
@property (nullable, nonatomic, retain) NSNumber *roomType;
@property (nullable, nonatomic, retain) NSSet<DeviceInfo *> *deviceInfo;
@property (nullable, nonatomic, retain) NSSet<SceneInfo *> *sceneInfo;

@end

@interface RoomInfo (CoreDataGeneratedAccessors)

- (void)addDeviceInfoObject:(DeviceInfo *)value;
- (void)removeDeviceInfoObject:(DeviceInfo *)value;
- (void)addDeviceInfo:(NSSet<DeviceInfo *> *)values;
- (void)removeDeviceInfo:(NSSet<DeviceInfo *> *)values;

- (void)addSceneInfoObject:(SceneInfo *)value;
- (void)removeSceneInfoObject:(SceneInfo *)value;
- (void)addSceneInfo:(NSSet<SceneInfo *> *)values;
- (void)removeSceneInfo:(NSSet<SceneInfo *> *)values;

@end

NS_ASSUME_NONNULL_END
