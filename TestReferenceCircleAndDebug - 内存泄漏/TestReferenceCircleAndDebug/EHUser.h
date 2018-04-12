//
//  EHUser.h
//  EHGhostDrone3
//
//  Created by XL on 2017/5/17.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHUser : NSObject

/** name */
@property (nonatomic , strong) NSString  *nickname;
@property (nonatomic , strong) NSString  *email;
@property (nonatomic , strong) NSString  *mobile;
@property (nonatomic , strong) NSString  *iconurl;
@property (nonatomic , strong) NSString  *birthday;
@property (nonatomic , strong) NSString  *location;
@property (nonatomic , strong) NSString  *userId;
@property (nonatomic , strong) NSString  *signature;
@property (nonatomic , assign) NSInteger gender;

/** 是否登录过,且有效 */
@property (nonatomic , assign , readonly) BOOL logined;
@property (nonatomic , strong) NSString  *token;

+ (instancetype)currentUser;

/**
 存储当前用户信息到沙盒 ,
 */
+ (void)storageCurrentUser;
/**
 用户退出,需要清空数据
 */
- (void)userExit;

/**
 如果字典中token信息为空,不会刷新token信息
 */
- (void)updateUserWithDict:(NSDictionary *)userDict;

@end
