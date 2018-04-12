//
//  EHNetwork.h
//  EHGhostDrone3
//
//  Created by XL on 2017/5/18.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EHLoginRequestData.h"
#import "EHUserModifiedRequestData.h"
#import "EHVerifycodeRequestData.h"
#import "EHUser.h"
#import <MJExtension.h>

#define XLSystemFont(font) [UIFont systemFontOfSize:font]
#define XLSystemBlodFont(font) [UIFont boldSystemFontOfSize:font]
#define XLRootViewController [UIApplication sharedApplication].windows.firstObject.rootViewController
#define XLUserDefaults [NSUserDefaults standardUserDefaults]
#define XLDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)
#define XLNoteCenter [NSNotificationCenter defaultCenter]
#define XLCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
#define XLAlertView(messageString , cancelTitle) [[[UIAlertView alloc] initWithTitle:nil message:messageString delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:nil, nil] show]
#define XLAlertViewShow(messageString , cancelTitle) XLAlertView(messageString , cancelTitle)

/**************************************/
/************     控制输出       **********/

#define XLLogFunc XLLog(@"%s",__func__)

#ifdef DEBUG
#define XLLog(...) NSLog(__VA_ARGS__)
#define XLFormatDebug 1
#else
#define XLLog(...)
#define XLFormatDebug 0
#endif


#if XLFormatDebug
#define XLFormatLog(...)\
{\
NSString *string = [NSString stringWithFormat:__VA_ARGS__];\
NSLog(@"\n===========================\n===========================\n=== XLFormatLog ===\n提示信息:%@\n所在方法:%s\n所在行数:%d\n===========================\n===========================",string,__func__,__LINE__);\
}
#else
#define XLFormatLog(...)
#endif

#if XLFormatDebug
#define XLErrorLog(...)\
{\
NSString *string = [NSString stringWithFormat:__VA_ARGS__];\
NSLog(@"\n===========================\n===========================\n=== XLErrorLog ===\n异常情况输出信息:%@\n所在方法:%s\n所在行数:%d\n===========================\n===========================",string,__func__,__LINE__);\
}
#else
#define XLErrorLog(...)
#endif

#define XLSTRINGIFY(S) #S
#define XLParamIsNil(param) \
if (!param) {\
XLErrorLog(@"%s为空",XLSTRINGIFY(param));\
return;\
}

typedef void(^requestSuccess)(id responseObject);
typedef void(^requestFailure)(NSError *error);

@interface EHNetwork : NSObject

/**
 用户登录

 @param data 发送登录请求所需的数据
 @param success 登录成功的回调
 @param failure 登录失败的回调
 */
+ (void)loginWithLoginRequestData:(EHLoginRequestData *)data success:(requestSuccess)success failure:(requestFailure)failure;

/**
 获取用户信息

 @param success 获取成功的回调
 @param failure 获取失败的回调
 */
+ (void)getUserDetailDataWithSuccess:(requestSuccess)success failure:(requestFailure)failure;

/**
 修改用户信息

 @param data 需要修改的数据
 @param success 修改成功的回调
 @param failure 修改失败的回调
 */
+ (void)modifyUserWithRequestData:(EHUserModifiedRequestData *)data success:(requestSuccess)success failure:(requestFailure)failure;

/**
 获取验证码

 @param data 获取请求所需的数据
 @param success 获取成功的回调
 @param failure 获取失败的回调
 */
+ (void)getVerifycodeRequestData:(EHVerifycodeRequestData *)data success:(requestSuccess)success failure:(requestFailure)failure;

/**
 获取纠偏数据

 @param position 偏移数据的index
 @param offsetType 纠偏类型
 @param success 获取成功的回调
 @param failure 获取失败的回调
 */
//+(void)getGpsOffsetWithPosition:(long)position OffsetType:(OffsetType)offsetType Success:(requestSuccess)success failure:(requestFailure)failure;
@end
