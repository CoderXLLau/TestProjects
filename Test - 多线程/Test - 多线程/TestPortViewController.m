//
//  TestPortViewController.m
//  Test - 多线程
//
//  Created by Shannoon Liu on 2018/3/21.
//  Copyright © 2018年 CoderXL. All rights reserved.
//

#import "TestPortViewController.h"

@interface TestPortViewController ()

@end

@implementation TestPortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMachPort *remotePort;
    [remotePort sendBeforeDate:[NSDate date]
                         msgid:1
                    components:nil
                          from:nil
                      reserved:0];
}

@end
