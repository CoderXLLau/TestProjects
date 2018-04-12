//
//  EHAFNetworkHelper.h
//  EHGhostDrone3
//
//  Created by 区振轩 on 17/5/18.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EHAFNHelperResponse.h"
#import "TestSingleTon.h"


typedef void(^HttpRequestResultBlock)(EHAFNHelperResponse * helperResponse);

@interface EHAFNetworkHelper : NSObject

+ (void)getRequestWithUrl:(NSString *)url Params:(NSDictionary *)params ResultBlock:(HttpRequestResultBlock)block;


/**
 post请求

 @param url 地址
 @param params 请求参数
 @param headerParams header参数
 @param block 完成回调
 */
+ (void)postRequestWithUrl:(NSString *)url Params:(NSDictionary *)params HeaderParams:(NSDictionary *)headerParams ResultBlock:(HttpRequestResultBlock)block;


/**
 用于专门请求地图纠偏数据的方法

 @param url <#url description#>
 @param params <#params description#>
 @param block <#block description#>
 */
+ (void)postRequestForLocationPositionWithUrl:(NSString *)url Params:(NSDictionary *)params HeaderParams:(NSDictionary *)headerParams ResultBlock:(HttpRequestResultBlock)block;
@end
