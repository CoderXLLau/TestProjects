//
//  TestAFNetWoringLeaksViewController.m
//  TestReferenceCircleAndDebug
//
//  Created by XL on 2017/6/15.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "TestAFNetWoringLeaksViewController.h"
#import "EHAFNetworkHelper.h"
#import "EHNetwork.h"
#import "EHHttpUrl.h"
#import <AFHTTPSessionManager.h>

@interface TestAFNetWoringLeaksViewController ()

@end

@implementation TestAFNetWoringLeaksViewController


/**
 AF内部有内存泄漏,因为创建的Session实例不会释放掉
 解决方案: 对session创建一份就可以了  可以新建一个单例类来保存一份等方案都可行
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    {
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(50, 200, 250, 55);
        btn.backgroundColor = [UIColor grayColor];
        
        [btn setTitle:@"获取个人信息 - 调用封装工具" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(getUserInfo) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    {
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(50, 270, 250, 55);
        btn.backgroundColor = [UIColor grayColor];
        
        [btn setTitle:@"获取个人信息 - 直接调用AF" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(getUserInfoInAF) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}


- (void)getUserInfo
{
    __weak typeof(self) weakself = self;
    [EHNetwork getUserDetailDataWithSuccess:^(id responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        [weakself showMessage:responseObject];
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
        [weakself showMessage:error];
    }];
}


/**
 每次都创建manager会内存泄漏
 */
- (void)getUserInfoInAF
{
    NSDictionary * header = @{@"Token":[EHUser currentUser].token};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = nil;
    [manager.requestSerializer setValue:[EHUser currentUser].token forHTTPHeaderField:@"Token"];
    
    __weak typeof(self) weakself = self;

    [manager POST:EHGetUserDetailUrlString parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        EHAFNHelperResponse * response;
        @try {
            //            EHAFNHelperResponse * response = [EHAFNHelperResponse initWithDict:responseObject];
            response = [[EHAFNHelperResponse alloc] initWithDict:responseObject];
        } @catch (NSException *exception) {
            response = [[EHAFNHelperResponse alloc] init];
            response.isSucceeded = NO;
            response.errorCode = -1;
        } @finally {
            [weakself showMessage:responseObject];
            NSLog(@"responseObject = %@ , response = %@",responseObject , response);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        EHAFNHelperResponse * response = [[EHAFNHelperResponse alloc] init];
        response.isSucceeded = NO;
        response.errorCode = -2; //或者是token非法
        [weakself showMessage:error];

        NSLog(@"error = %@ , response = %@",error , response);
    }];
}

- (void)dealloc
{
    XLLogFunc;
}

@end
