//
//  ViewController.m
//  TestReferenceCircleAndDebug
//
//  Created by XL on 2017/5/27.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "ViewController.h"
#import "ReferenceCirlceViewController.h"
#import "TestAFNetWoringLeaksViewController.h"
#import "TestSingleTonLeaksViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    {
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(100, 100, 200, 55);
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitle:@"进入基本循环引用测试页面" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    {
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(100, 200, 200, 55);
        btn.backgroundColor = [UIColor grayColor];
        
        [btn setTitle:@"进入AF测试页面" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickAFButton) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }

    {
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(100, 270, 200, 55);
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitle:@"进入单例测试页面" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickSingleTonButton) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

- (void)clickBtn
{
    ReferenceCirlceViewController *vc = [[ReferenceCirlceViewController alloc] init];
    vc.title = @"ReferenceCirlceViewController";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clickAFButton
{
    TestAFNetWoringLeaksViewController *tempVC = [[TestAFNetWoringLeaksViewController alloc] init];
    tempVC.title = @"TestAFNetWoringLeaksViewController";
    [self.navigationController pushViewController:tempVC animated:YES];
}

- (void)clickSingleTonButton
{
    TestSingleTonLeaksViewController *tempVC = [[TestSingleTonLeaksViewController alloc] init];
    tempVC.title = @"TestSingleTonLeaksViewController";
    [self.navigationController pushViewController:tempVC animated:YES];
}

@end
