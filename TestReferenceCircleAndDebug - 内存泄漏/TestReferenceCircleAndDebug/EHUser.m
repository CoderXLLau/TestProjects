//
//  EHUser.m
//  EHGhostDrone3
//
//  Created by XL on 2017/5/17.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import "EHUser.h"
#define EHUserInfoKey @"EHUserInfoKey"

@interface EHUser ()

@end

@implementation EHUser

#pragma mark    -   init 

static id _instance;
+ (instancetype)currentUser
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (NSString *)token
{
    return @"7bad2fd494c34787a323bb6a59d03c41";
}

#pragma mark    -   public

- (void)userExit
{
    self.token = nil;
    [self updateUserWithDict:nil];
}

/**
 存储当前用户信息到沙盒
 */
+ (void)storageCurrentUser
{
}

#pragma mark    -   private

/**
 如果字典中token信息为空,不会刷新token信息
 */
- (void)updateUserWithDict:(NSDictionary *)userDict
{
    self.userId = userDict[@"userId"];
    self.nickname = userDict[@"nickname"];
    self.email = userDict[@"email"];
    self.iconurl = userDict[@"iconurl"];
    self.birthday = userDict[@"birthday"];
    self.mobile = userDict[@"mobile"];
    self.location = userDict[@"location"];
    self.gender = [userDict[@"gender"] integerValue];
    if (userDict[@"token"]) {
        self.token = userDict[@"token"];
    }
    
    [self storageCurrentUser];
}

- (void)storageCurrentUser
{

}

#pragma mark    -   get / set

- (BOOL)logined
{
    return self.token.length > 0;
}

@end
