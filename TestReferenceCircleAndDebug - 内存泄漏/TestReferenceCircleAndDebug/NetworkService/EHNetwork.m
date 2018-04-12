//
//  EHNetwork.m
//  EHGhostDrone3
//
//  Created by XL on 2017/5/18.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import "EHHttpUrl.h"
#import "EHNetwork.h"
#import "EHAFNetworkHelper.h"
#import "EHAFNHelperResponse.h"

@implementation EHNetwork

+ (void)getVerifycodeRequestData:(EHVerifycodeRequestData *)data success:(requestSuccess)success failure:(requestFailure)failure{
    NSDictionary * data1 = [data mj_JSONObject];
    XLParamIsNil(data1);
    NSDictionary * params = @{@"platform":@"1",@"data":data1};
    
    [EHAFNetworkHelper postRequestWithUrl:EHGetVerifyCodeUrlString Params:params HeaderParams:nil ResultBlock:^(EHAFNHelperResponse *helperResponse) {
        [EHNetwork analyzing:helperResponse success:success failure:failure];
    }];
}

+ (void)getUserDetailDataWithSuccess:(requestSuccess)success failure:(requestFailure)failure{
//    if (![EHUser currentUser].token) {
//        XLErrorLog(@"[EHUser currentUser].token为空");
//        return;
//    }
    XLParamIsNil([EHUser currentUser].token);

    NSDictionary * header = @{@"Token":[EHUser currentUser].token};
    [EHAFNetworkHelper postRequestWithUrl:EHGetUserDetailUrlString Params:nil HeaderParams:header ResultBlock:^(EHAFNHelperResponse *helperResponse) {
        [EHNetwork analyzing:helperResponse success:success failure:failure];
    }];
}

+ (void)modifyUserWithRequestData:(EHUserModifiedRequestData *)data success:(requestSuccess)success failure:(requestFailure)failure{
    NSDictionary * data1 = [data mj_JSONObject];
    XLParamIsNil(data1);
    XLParamIsNil([EHUser currentUser].token);
    NSDictionary * params = @{@"data":data1};
    NSDictionary * header = @{@"Token":[EHUser currentUser].token};
    [EHAFNetworkHelper postRequestWithUrl:EHModifyUserUrlString Params:params HeaderParams:header ResultBlock:^(EHAFNHelperResponse *helperResponse) {
        [EHNetwork analyzing:helperResponse success:success failure:failure];
    }];
}

+ (void)loginWithLoginRequestData:(EHLoginRequestData *)data success:(requestSuccess)success failure:(requestFailure)failure{
    
    NSDictionary * data1 = [data mj_JSONObject];
    XLParamIsNil(data1);
    NSDictionary * params = @{@"platform":@"1",@"data":data1};
    
    [EHAFNetworkHelper postRequestWithUrl:EHLoginUrlString Params:params HeaderParams:nil ResultBlock:^(EHAFNHelperResponse *helperResponse) {
        [EHNetwork analyzing:helperResponse success:success failure:failure];
    }];
}

//+(void)getGpsOffsetWithPosition:(long)position OffsetType:(OffsetType)offsetType Success:(requestSuccess)success failure:(requestFailure)failure{
//    //    NSString * type = offsetType==Anti ? @"Anti" : @"Org";
//    //    NSDictionary * params = @{@"position":@(position),@"type":type};
//    
//    int type = offsetType==Anti ? 1 : 2;
//    NSDictionary * data1 = @{@"position":@(position),@"type":@(type)};
//    NSDictionary * params = @{@"data":data1};
//    [EHAFNetworkHelper postRequestForLocationPositionWithUrl:@"http://139.219.187.95:60001/api/app/get_gps_offset" Params:params HeaderParams:nil ResultBlock:^(EHAFNHelperResponse *helperResponse) {
//        [EHNetwork analyzing:helperResponse success:success failure:failure];
//    }];
//}
#pragma mark    -   解析返回信息
+ (void)analyzing:(EHAFNHelperResponse *)helperResponse success:(requestSuccess)success failure:(requestFailure)failure{
    if (helperResponse.isSucceeded) {
        if(success) {
            success(helperResponse.data);
        }
    }else{
        NSString* errorMessage = [EHNetwork translateWithErrorCode:helperResponse.errorCode];
        NSError *error = [NSError errorWithDomain:errorMessage code:helperResponse.errorCode userInfo:nil];
        if (failure) {
            failure(error);
        }
    }
}
+(NSString *)translateWithErrorCode:(long)errorCode
{
    NSString* errorMessage = @"";
    switch (errorCode) {
        case -2:
            errorMessage =  NSLocalizedString(@"网络异常",nil);
            break;
        case -1:
            errorMessage =  NSLocalizedString(@"解析数据异常",nil);
            break;
        case 0:
            errorMessage =  NSLocalizedString(@"没有错误",nil);
            break;
        case 1:
            errorMessage =  NSLocalizedString(@"无权访问",nil);
            break;
        case 2:
            errorMessage =  NSLocalizedString(@"用户渠道类型设置错误",nil);
            break;
        case 3:
            errorMessage =  NSLocalizedString(@"手机号格式错误",nil);
            break;
        case 4:
            errorMessage =  NSLocalizedString(@"邮箱格式错误",nil);
            break;
        case 5:
            errorMessage =  NSLocalizedString(@"第三方登陆用户Id为空",nil);
            break;
        case 6:
            errorMessage =  NSLocalizedString(@"验证码错误",nil);
            break;
        case 7:
            errorMessage =  NSLocalizedString(@"用户渠道类型错误",nil);
            break;
        case 8:
            errorMessage =  NSLocalizedString(@"Token错误,获取不到Session",nil);
            break;
        case 9:
            errorMessage =  NSLocalizedString(@"系统中不存在该项目",nil);
            break;
        case 10:
            errorMessage =  NSLocalizedString(@"不是base64编码的图片",nil);
            break;
        case 11:
            errorMessage =  NSLocalizedString(@"更新数据失败",nil);
            break;
        case 12:
            errorMessage =  NSLocalizedString(@"创建失败",nil);
            break;
        case 13:
            errorMessage =  NSLocalizedString(@"登陆未知错误",nil);
            break;
        case 14:
            errorMessage =  NSLocalizedString(@"验证码发送失败",nil);
            break;
        case 15:
            errorMessage =  NSLocalizedString(@"验证码类型设置错误",nil);
            break;
        case 16:
            errorMessage =  NSLocalizedString(@"参数值不在合法范围内",nil);
            break;
        default:
            break;
    }
    return errorMessage;
}
@end
