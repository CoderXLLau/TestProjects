//
//  EHUserModifiedRequestData.h
//  EHGhostDrone3
//
//  Created by 刘畅 on 2017/5/18.
//  Copyright © 2017年 Ehang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHUserModifiedRequestData : NSObject

/**
 生日
 */
@property (nonatomic,assign) NSString* birthday;

/**
 昵称
 */
@property (nonatomic,assign) NSString* nickname;

/**
 所属地区 格式为“Country,Province,City”
 */
@property (nonatomic,assign) NSString* location;

    #warning TODO 此处不给gender赋值它也会出现在字典里面
/**
  性别 EHGender
 */
@property (nonatomic,assign) NSInteger gender;

/**
 用户图像base64编码
 */
@property (nonatomic,assign) NSString* icon;


@end
