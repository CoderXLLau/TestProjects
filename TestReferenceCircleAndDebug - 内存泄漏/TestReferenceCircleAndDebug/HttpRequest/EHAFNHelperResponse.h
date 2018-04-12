//
//  EHAFNHelperResponse.h
//  EHGhostDrone3
//
//  Created by 区振轩 on 17/5/18.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHAFNHelperResponse : NSObject

@property (nonatomic,assign) BOOL isSucceeded;
@property (nonatomic,assign) long errorCode;
@property (nonatomic,strong) id data;

- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)initWithDict:(NSDictionary *)dict;

@end
