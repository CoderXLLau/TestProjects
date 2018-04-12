//
//  BaseViewController.h
//  Test - 多线程
//
//  Created by XL on 2017/6/27.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+DeallocBlock.h"

@interface BaseViewController : UIViewController

@property (nonatomic , strong , readonly) NSMutableDictionary  *dict;

- (void)addTestButtonWithTitle:(NSString *)buttonTitle selector:(SEL)selector;

@end
