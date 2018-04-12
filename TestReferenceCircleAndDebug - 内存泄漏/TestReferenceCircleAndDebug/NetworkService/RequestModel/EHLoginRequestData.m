//
//  EHLoginRequestData.m
//  EHGhostDrone3
//
//  Created by 刘畅 on 2017/5/18.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import "EHLoginRequestData.h"
#import <MJExtension.h>

static EHLoginRequestData *loginData = nil;

@implementation EHLoginRequestData

+ (instancetype)loginData
{
    loginData = [[EHLoginRequestData alloc] init];
    return loginData;
}

+(NSDictionary *)replacedKeyFromPropertyName
{
    return @{
             @"thirdPartyUserid":@"userid",
             @"thirdPartyNickname" : @"nickname",
             @"thirdPartyGender":@"gender",
             @"thirdPartyIconurl":@"iconurl",
             };
}

@end
