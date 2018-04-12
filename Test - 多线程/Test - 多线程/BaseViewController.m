//
//  BaseViewController.m
//  Test - 多线程
//
//  Created by XL on 2017/6/27.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "BaseViewController.h"


@interface BaseViewController ()

@property (nonatomic , strong) NSMutableDictionary  *dict;

@end

@implementation BaseViewController

- (void)loadView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.frame = [UIScreen  mainScreen].bounds;
    scrollView.contentSize = CGSizeMake(0, 1500);
    self.view = scrollView;
    self.dict = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass([self class]);
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)addTestButtonWithTitle:(NSString *)buttonTitle selector:(SEL)selector
{
    [self.dict setObject:NSStringFromSelector(selector) forKey:buttonTitle];
    CGFloat buttonWidth = [UIScreen mainScreen].bounds.size.width - 20;
    UIButton *btn = [[UIButton alloc] init];
    [self.view addSubview:btn];
    btn.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
    [btn setTitle:buttonTitle forState:UIControlStateNormal];
    btn.frame = CGRectMake(10, 20+ 44 *self.dict.count, buttonWidth, 36);
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIScrollView *scrollView = (UIScrollView *)self.view;
    btn.layer.cornerRadius = 3;
    btn.layer.masksToBounds = YES;
    scrollView.contentSize = CGSizeMake(0, 100 + 44 *self.dict.count);
}

@end
