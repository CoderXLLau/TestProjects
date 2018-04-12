//
//  EHVerifycodeRequestData.h
//  EHGhostDrone3
//
//  Created by 刘畅 on 2017/5/18.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SendType) {
    SendTypeSMS=1,
    SendTypeMail
};

@interface EHVerifycodeRequestData : NSObject

/**
 用户账号
 */
@property (nonatomic,assign) NSString* account;

/**
 1 短信
 2 邮件
 */
@property (nonatomic,assign) SendType type;

/**
 语言
 */
@property (nonatomic,assign) NSString* lang;

@end
