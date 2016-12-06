//
//  DeviceInfo+CoreDataProperties.h
//  Smart_home
//
//  Created by 彭子上 on 2016/9/5.
//  Copyright © 2016年 彭子上. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DeviceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *deviceCreateDate;
@property (nullable, nonatomic, retain) NSString *deviceCustomName;
@property (nullable, nonatomic, retain) NSString *deviceInfaredCode;
@property (nullable, nonatomic, retain) NSString *deviceInfraredID;
@property (nullable, nonatomic, retain) NSString *deviceMacID;
@property (nullable, nonatomic, retain) NSString *deviceRemoteMac;
@property (nullable, nonatomic, retain) NSNumber *deviceSceneStatus;
@property (nullable, nonatomic, retain) NSNumber *deviceStatus;
@property (nullable, nonatomic, retain) NSNumber *deviceTapCount;
@property (nullable, nonatomic, retain) NSString *deviceType;
@property (nullable, nonatomic, retain) NSNumber *isCommonDevice;

//@property (nullable, nonatomic, retain) NSSet<RoomInfo *> *roomInfo;

@property (nullable, nonatomic, retain) RoomInfo *roomInfo;

@end

NS_ASSUME_NONNULL_END
