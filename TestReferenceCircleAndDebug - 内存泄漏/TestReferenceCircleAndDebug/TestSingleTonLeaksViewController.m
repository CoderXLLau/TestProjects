//
//  TestSingleTonLeaksViewController.m
//  TestReferenceCircleAndDebug
//
//  Created by XL on 2017/6/15.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "TestSingleTonLeaksViewController.h"
#import "TestSingleTon.h"

@interface TestSingleTonLeaksViewController ()

@property (nonatomic , strong) TestSingleTon *singleTon;

@end

@implementation TestSingleTonLeaksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    TestSingleTon *singleTon = [TestSingleTon sharedSingleTon];
    singleTon.nickName = @"hahaha";
    self.singleTon = singleTon;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.singleTon.phone = @"110110110";
    });
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
