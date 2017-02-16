//
//  TTSCoreDataManager.h
//  Smart_home
//
//  Created by 彭子上 on 2016/7/2.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreData/CoreData.h"

@class DeviceInfo;
@class RoomInfo;
@class SceneInfo;

@interface TTSCoreDataManager : NSObject

@property(retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(retain, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(retain, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (TTSCoreDataManager *)getInstance;

- (NSManagedObject *)getNewManagedObjectWithEntiltyName:(NSString *)entityName;

- (NSMutableArray *)getResultArrWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate;

- (void)insertDataWithObject:(NSManagedObject *)object;

- (void)deleteDataWithObject:(NSManagedObject *)object;

- (void)updateData;

//- (void)insertDevice:(DeviceInfo *)deviceInfo roomInfo:(RoomInfo *)roomInfo sceneInfo:(SceneInfo *)sceneInfo;

@end
