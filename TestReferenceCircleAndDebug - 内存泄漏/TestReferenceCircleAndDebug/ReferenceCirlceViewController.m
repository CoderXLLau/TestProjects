//
//  ReferenceCirlceViewController.m
//  TestReferenceCircleAndDebug
//
//  Created by XL on 2017/5/27.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "ReferenceCirlceViewController.h"

@interface ReferenceCirlceViewController ()

@property (nonatomic , strong)NSMutableArray *oneArray;
@property (nonatomic , strong)NSMutableArray *twoArray;

@end

@implementation ReferenceCirlceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];

    NSMutableArray *firstArray = [NSMutableArray array];
    NSMutableArray *secondArray = [NSMutableArray array];
    for (int i = 0 ; i < 1000; i ++) {
        @autoreleasepool {
            NSString *str = [NSString stringWithFormat:@"当前i = %zd",i];
            NSLog(@"%p",str);
            [firstArray addObject:str];
            [secondArray addObject:str];
        }
    }
    [firstArray addObject:secondArray];
    [secondArray addObject:firstArray];
//    self.oneArray = [NSMutableArray array];
//    self.twoArray = [NSMutableArray array];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.oneArray addObject:self.twoArray];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self change];
//    });
}

- (void)change
{
    [self.twoArray addObject:self.oneArray];
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
