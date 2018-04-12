//
//  ViewController.m
//  Test - 多线程
//
//  Created by XL on 2017/6/26.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "ViewController.h"
#import "PthreadViewController.h"
#import "NSThreadViewController.h"
#import "GCDViewController.h"
#import "NSOperationViewController.h"
#import "ThreadSafeViewController.h"
#import "RunLoopViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTestButtonWithTitle:@"PthreadViewController" selector:@selector(jumpToSpecificViewController:)];
    [self addTestButtonWithTitle:@"NSThreadViewController" selector:@selector(jumpToSpecificViewController:)];
    [self addTestButtonWithTitle:@"GCDViewController" selector:@selector(jumpToSpecificViewController:)];
    [self addTestButtonWithTitle:@"NSOperationViewController" selector:@selector(jumpToSpecificViewController:)];
    [self addTestButtonWithTitle:@"ThreadSafeViewController" selector:@selector(jumpToSpecificViewController:)];
    [self addTestButtonWithTitle:@"RunLoopViewController" selector:@selector(jumpToSpecificViewController:)];
}

- (void)jumpToSpecificViewController:(UIButton *)btn
{
    UIViewController *tempVC = [[NSClassFromString(btn.titleLabel.text) alloc] init];
    NSAssert([tempVC isKindOfClass:[UIViewController class]], @"按钮名字和对应的控制器名字不一致,无法创建控制器,请修改");
    [self.navigationController pushViewController:tempVC animated:YES];
}

@end


