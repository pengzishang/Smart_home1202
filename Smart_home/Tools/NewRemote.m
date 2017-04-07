//
//  NewRemote.m
//  Smart_home
//
//  Created by 彭子上 on 2017/4/6.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import "NewRemote.h"

@implementation NewRemote


- (void)sendDataToServerWithUrlstr:(NSString *)urlstr interface:(NSString *)interfaceStr requestBody:(NSDictionary *)body success:(void (^ _Nullable)(NSDictionary *_Nullable))success fail:(void (^ _Nullable)(NSError *_Nullable))fail {
    
    NSString *url = [urlstr stringByAppendingString:[NSString stringWithFormat:@"%@?wsdl", interfaceStr]];
    NSString *requestStr = [self makeRequestStrWithBody:body interface:interfaceStr];
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    session.responseSerializer = [AFHTTPResponseSerializer serializer];
    session.requestSerializer.timeoutInterval = 3.0;
    //得到头信息
    [session.requestSerializer setQueryStringSerializationWithBlock:
     ^NSString * _Nonnull(NSURLRequest *
                          _Nonnull request, id _Nonnull parameters, NSError
                          * _Nullable __autoreleasing *
                          _Nullable error) {
         return requestStr;
     }];
    
    __block NSDictionary *dict = [NSDictionary dictionary];
    [session POST:url parameters:requestStr progress:nil success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        //成功解析则回调成功信息        //正则解析
        dict = [self translateFromData:responseObject];
        if (success) {
            success(dict);
        }
    }     failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        if (fail) {
            NSLog(@"错误原因:%@", error.description);
            fail(error);
        }
    }];
}

/**
 *  从接口名获取回应请求体
 *
 *  @param body          <#body description#>
 *  @param interfaceName <#interfaceName description#>
 *
 *  @return 回复请求体
 */
- (NSString *)makeRequestStrWithBody:(NSDictionary *)body interface:(NSString *)interfaceName {
    NSString *headStr = @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><%@ xmlns=\"http://wwdog.org/\">";
    __block NSString *resUrl = [NSString stringWithFormat:headStr, interfaceName];
    
    [body enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
        NSString *subStr = [NSString stringWithFormat:@"<%@>%@</%@>", key, obj, key];
        resUrl = [resUrl stringByAppendingString:subStr];
    }];
    
    resUrl = [resUrl stringByAppendingString:[NSString stringWithFormat:@"</%@></soap:Body></soap:Envelope>", interfaceName]];
    
    return resUrl;
}

//正则解析字符串  系统解析JSON

- (NSDictionary *)translateFromData:(NSData *)responseObject {
    NSString *resp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    NSRegularExpression *result = [[NSRegularExpression alloc] initWithPattern:@"(?<=return\\>).*(?=</return)" options:NSRegularExpressionCaseInsensitive error:nil];
    
    __block NSDictionary *dict = [NSDictionary dictionary];
    NSArray *resultArr = [result matchesInString:resp options:0 range:NSMakeRange(0, resp.length)];
    [resultArr enumerateObjectsUsingBlock:^(NSTextCheckingResult *_Nonnull checkingResult, NSUInteger idx, BOOL *_Nonnull stop) {
        
        dict = [NSJSONSerialization JSONObjectWithData:[[resp substringWithRange:checkingResult.range] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        
    }];
    return dict;
}

@end
