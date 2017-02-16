//
//  TTSCoreDataManager.m
//  Smart_home
//
//  Created by 彭子上 on 2016/7/2.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "TTSCoreDataManager.h"

static TTSCoreDataManager *shareInstance = nil;

@implementation TTSCoreDataManager

+ (TTSCoreDataManager *)getInstance {
    if (shareInstance == nil) {

        shareInstance = [[TTSCoreDataManager alloc] init];
        [shareInstance manageObjectContext];
    }

    return shareInstance;
}

- (NSManagedObjectModel *)manageObjectModel {
    if (_managedObjectModel == nil) {

        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator == nil) {

        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.manageObjectModel];

        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

        NSString *dataBasePath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"Documents/coreDate.sqlite"];

        NSURL *url = [[NSURL alloc] initFileURLWithPath:dataBasePath];
        NSError *error;

        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]) {
        }

    }


    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)manageObjectContext {
    if (_managedObjectContext == nil) {

        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];//5.20日修改,异常改回
        _managedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    }

    return _managedObjectContext;
}


#pragma mark - methodes

- (NSManagedObject *)getNewManagedObjectWithEntiltyName:(NSString *)entityName {
    NSManagedObject *manageObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];

    if (!manageObject) {

        NSLogMethodArgs(@"没有该表");
    }

    return manageObject;
}

- (NSMutableArray *)getResultArrWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate {
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];//要查的表
    request.predicate = predicate;
    NSMutableArray *result = (NSMutableArray *) [_managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLogMethodArgs(@"error:%@", error.description);
    }
    return result;
}

- (void)insertDataWithObject:(NSManagedObject *)object {
    /******
     *insertObject 临时的插入，在关闭程序前能检索出来，但没有真正的保存
     *save 后才真的保存
     *不用insertObject 直接 save 也是可以的
     *******/

    [_managedObjectContext insertObject:object];

    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {

        NSLogMethodArgs(@"error:%@", error.description);
    }
}

- (void)updateData {
    /***
     *更新已有的数据对象，只要save 就可以了。
     */

    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {

        NSLogMethodArgs(@"error:%@", error.description);
    }

}

- (void)deleteDataWithObject:(NSManagedObject *)object {
    /**
     *deleteObject 临时删除
     */
    [_managedObjectContext deleteObject:object];

    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {

        NSLogMethodArgs(@"error:%@", error.description);
    }

}

//- (void)insertDevice:(DeviceInfo *)deviceInfo roomInfo:(RoomInfo *)roomInfo sceneInfo:(SceneInfo *)sceneInfo
//{
//    [self getNewManagedObjectWithEntiltyName:@"DeviceInfo"];
//}

@end
