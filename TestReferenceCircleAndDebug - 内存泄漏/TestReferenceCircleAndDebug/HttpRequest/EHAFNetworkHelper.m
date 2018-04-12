//
//  EHAFNetworkHelper.m
//  EHGhostDrone3
//
//  Created by 区振轩 on 17/5/18.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import "EHAFNetworkHelper.h"
#import <AFNetworking.h>
#import "EHUser.h"

@interface EHAFNetworkHelper ()

@property (nonatomic , strong)AFHTTPSessionManager *manager;

@end

@implementation EHAFNetworkHelper

//static id _instance;
//+ (instancetype)sharedHelper
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _instance = [[self alloc] init];
//    });
//    return _instance;
//}
//
//- (instancetype)init
//{
//    if (self = [super init]) {
//        
//        self.manager = [AFHTTPSessionManager manager];
//    }
//    return self;
//}

+ (void)initialize
{
    _manager = [AFHTTPSessionManager manager];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    _manager.responseSerializer.acceptableContentTypes = nil;
}

static AFHTTPSessionManager *_manager ;

+ (void)getRequestWithUrl:(NSString *)url Params:(NSDictionary *)params ResultBlock:(HttpRequestResultBlock)block{
    
    HttpRequestResultBlock result = nil;
    result = [block copy];
    
    EHAFNHelperResponse * response = [[EHAFNHelperResponse alloc] init];
    
    
    [_manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

             id resultx = [NSJSONSerialization JSONObjectWithData:((NSData *)responseObject) options:NSJSONReadingAllowFragments error:nil];
             
             if (![resultx isKindOfClass:[NSDictionary class]]) {
                 response.isSucceeded = NO;
             }
             response.isSucceeded = [resultx objectForKey:@"isSucceeded"];
             response.errorCode = [[resultx objectForKey:@"errorCode"] intValue];
             response.data = [resultx objectForKey:@"data"];
             
             result(response);
         }
     
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
             response.isSucceeded = NO;
             NSLog(@"%@",error);  //这里打印错误信息
         }];
}

+ (void)postRequestWithUrl:(NSString *)url Params:(NSDictionary *)params HeaderParams:(NSDictionary *)headerParams ResultBlock:(HttpRequestResultBlock)block{
    
    HttpRequestResultBlock result = nil;
    result = [block copy];
    
    if (headerParams != nil) {
        for (NSString * key in headerParams.allKeys) {
            NSString * value = headerParams[key];
            [_manager.requestSerializer setValue:value forHTTPHeaderField:key];
        }
    }
    
    [_manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        @try {
//            EHAFNHelperResponse * response = [EHAFNHelperResponse initWithDict:responseObject];
            EHAFNHelperResponse * response = [[EHAFNHelperResponse alloc] initWithDict:responseObject];
            result(response);
        } @catch (NSException *exception) {
            EHAFNHelperResponse * response = [[EHAFNHelperResponse alloc] init];
            response.isSucceeded = NO;
            response.errorCode = -1;
            result(response);
        } @finally {
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EHAFNHelperResponse * response = [[EHAFNHelperResponse alloc] init];
        response.isSucceeded = NO;
        response.errorCode = -2; //或者是token非法
        result(response);
    }];

}

+ (void)postRequestForLocationPositionWithUrl:(NSString *)url
                                       Params:(NSDictionary *)params
                                 HeaderParams:(NSDictionary *)headerParams
                                  ResultBlock:(HttpRequestResultBlock)block{
    
    
    
    url = @"http://139.219.187.95:60001/api/app/get_gps_offset";
    HttpRequestResultBlock result = nil;
    result = [block copy];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[EHUser currentUser].token forHTTPHeaderField:@"Token"];
    manager.responseSerializer.acceptableContentTypes = nil;
    
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            EHAFNHelperResponse * response = [[EHAFNHelperResponse alloc] init];
            NSData * data = [NSData dataWithData:responseObject];
//            正常返回的数据大于100000，错误信息只有40+
            if (data.length < 10000) {
                EHAFNHelperResponse * response = [[EHAFNHelperResponse alloc] init];
                response.isSucceeded = NO;
                response.errorCode = -1;
                result(response);
            }else{
                response.isSucceeded = YES;
                response.data = data;
                result(response);
            }
        }
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EHAFNHelperResponse * response = [[EHAFNHelperResponse alloc] init];
        response.isSucceeded = NO;
        response.errorCode = -2; //或者是token非法
        result(response);
    }];
 
//    url = @"http://appservice.ehang.com/interface/get_gps_offset.php";
//    HttpRequestResultBlock result = nil;
//    result = [block copy];
//    NSString * type = params[@"type"];
//    long position = [params[@"position"] longValue];
//    NSString *postDataStr = [NSString stringWithFormat:@"position=%ld&type=%@",position,type];
//    NSLog(@"postDataStr: %@",postDataStr);
//    NSData* infoData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * finalData = infoData;
//    NSString* thePostDataLength = [NSString stringWithFormat:@"%d", (int)[finalData length]];
//    
//    NSMutableURLRequest* request = NULL;
//    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
//    [request addValue:thePostDataLength forHTTPHeaderField:@"Content-Length"];
//    [request setHTTPBody:finalData]; [request setHTTPMethod:@"POST"];
//    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    request.timeoutInterval = 15;
//    
////    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
//    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
//                                                 @"text/html",
//                                                 nil];
//    
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//
//    manager.responseSerializer = responseSerializer;
//
//    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//
//        NSData * data = [NSData dataWithData:responseObject];
//        EHAFNHelperResponse * response1 = [[EHAFNHelperResponse alloc] init];
//
//        if (!error) {
////            su
//            response1.isSucceeded = YES;
//            response1.data = data;
//            result(response1);
//        } else {
//            response1.isSucceeded = YES;
//            response1.data = data;
//            result(response1);
//    }
//    }] resume];

    
    
}

@end



















