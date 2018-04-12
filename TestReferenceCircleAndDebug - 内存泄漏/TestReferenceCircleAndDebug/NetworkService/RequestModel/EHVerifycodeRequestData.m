//
//  EHVerifycodeRequestData.m
//  EHGhostDrone3
//
//  Created by 刘畅 on 2017/5/18.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import "EHVerifycodeRequestData.h"

static EHVerifycodeRequestData * verifycodeRequestData = nil;

@implementation EHVerifycodeRequestData

+ (instancetype)verifycodeRequestData
{
    verifycodeRequestData = [[EHVerifycodeRequestData alloc] init];
    return verifycodeRequestData;
}

@end
