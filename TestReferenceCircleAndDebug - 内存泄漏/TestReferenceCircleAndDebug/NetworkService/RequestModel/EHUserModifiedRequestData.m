//
//  EHUserModifiedRequestData.m
//  EHGhostDrone3
//
//  Created by 刘畅 on 2017/5/18.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import "EHUserModifiedRequestData.h"

static EHUserModifiedRequestData *userModifiedRequestData = nil;

@implementation EHUserModifiedRequestData

+ (instancetype)userModifiedRequestData
{
    userModifiedRequestData = [[EHUserModifiedRequestData alloc] init];
    return userModifiedRequestData;
}

@end
