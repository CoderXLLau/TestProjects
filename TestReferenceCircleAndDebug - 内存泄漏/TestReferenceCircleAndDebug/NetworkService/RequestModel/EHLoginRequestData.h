//
//  EHLoginRequestData.h
//  EHGhostDrone3
//
//  Created by 刘畅 on 2017/5/18.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ChannelType) {
    ChannelTypeMobile = 1,
    ChannelTypeMail,
    ChannelTypeWechat,
    ChannelTypeSinaWeibo,
    ChannelTypeFacebook
};

@interface EHLoginRequestData : NSObject

/**
 用户登录渠道类型 
 1 手机
 2 邮箱
 3:Wechat,
 4:SinaWeibo,
 5:Facebook
 */
@property (nonatomic,assign) ChannelType channelType;

/**
 手机号
 */
@property (nonatomic,assign) NSString* mobile;

/**
 邮箱
 */
@property (nonatomic,assign) NSString* email;

/**
 验证码
 */
@property (nonatomic,assign) NSString* verifycode;

/**
  下列数据均为第三方平台返回的数据
 */

/**
 userid
 */
@property (nonatomic,assign) NSString* thirdPartyUserid;

/**
 nickname
 */
@property (nonatomic,assign) NSString* thirdPartyNickname;

/**
 性别 
 */
@property (nonatomic,assign) NSInteger thirdPartyGender;

/**
 用户图像Url
 */
@property (nonatomic,assign) NSString* thirdPartyIconurl;

@end
