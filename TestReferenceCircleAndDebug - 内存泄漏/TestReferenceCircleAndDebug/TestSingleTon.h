//
//  TestSingleTon.h
//  TestReferenceCircleAndDebug
//
//  Created by XL on 2017/6/15.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import <Foundation/Foundation.h>

/**************************************/
/************     单例       **********/
// 单例.h文件
#define XLSingletonH(name) + (instancetype)shared##name;
// 单例.m文件
#define XLSingletonM(name) \
static id _instance; \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
\
+ (instancetype)shared##name \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return _instance; \
}\


@interface TestSingleTon : NSObject

@property (nonatomic , strong) NSString  *nickName;
@property (nonatomic , strong) NSString  *phone;
@property (nonatomic , strong) NSString  *address;
@property (nonatomic , strong) NSString  *email;

XLSingletonH(SingleTon);

@end
