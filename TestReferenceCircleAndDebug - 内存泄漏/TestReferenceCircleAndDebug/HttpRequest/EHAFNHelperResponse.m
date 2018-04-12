//
//  EHAFNHelperResponse.m
//  EHGhostDrone3
//
//  Created by 区振轩 on 17/5/18.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import "EHAFNHelperResponse.h"

@implementation EHAFNHelperResponse


+ (instancetype)initWithDict:(NSDictionary *)dict
{
    EHAFNHelperResponse * response = [[EHAFNHelperResponse alloc] init];
    [response setValuesForKeysWithDictionary:dict];
    return response;
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
