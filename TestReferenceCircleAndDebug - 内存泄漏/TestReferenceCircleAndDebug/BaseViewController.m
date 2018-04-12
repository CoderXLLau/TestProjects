//
//  BaseViewController.m
//  TestReferenceCircleAndDebug
//
//  Created by XL on 2017/6/15.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    NSLog(@"%@ dealloc" , NSStringFromClass([self class]));
}

- (void)showMessage:(id)message
{
    [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@",message] delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil] show];
}

@end
