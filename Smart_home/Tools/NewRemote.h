//
//  NewRemote.h
//  Smart_home
//
//  Created by 彭子上 on 2017/4/6.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface NewRemote : NSObject


- (void)sendDataToServerWithUrlstr:(NSString *__nonnull)urlstr
                         interface:(NSString *__nonnull)interfaceStr
                       requestBody:(NSDictionary *_Nullable)body
                           success:(void (^ _Nullable)(NSDictionary *__nullable requestDic))success
                              fail:(void (^ _Nullable)(NSError *__nullable error))fail;

@end
