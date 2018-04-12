//
//  XLOperation.m
//  Test - 多线程
//
//  Created by XL on 2017/7/3.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "XLOperation.h"

@implementation XLOperation

/**
 * 需要执行的任务
 */
- (void)main
{
    //捕获异常
    @try {
        //在这里我们要创建自己的释放池，因为子线程运行循环默认不工作，不会主动创建自动释放池
        @autoreleasepool {
            if (self.isCancelled)
            {
                NSLog(@"0000self.isCancelled = yes , return");
                return;
            }
        
            for (NSInteger i = 0; i<100; i++) {
                [NSThread sleepForTimeInterval:0.1];
                NSString *string = [NSString stringWithFormat:@"XLOperation1 %zd",i];
                NSLog(@"XLOperation1 -%zd -- isCanceled = %zd-- executing=%zd -- isFinished = %zd -- %@", i, self.isCancelled,self.executing,self.isFinished,[NSThread currentThread]);
            }
            if (self.isCancelled)
            {
                NSLog(@"1111self.isCancelled = yes , return");
                return;
            }
            
            for (NSInteger i = 0; i<100; i++) {
                [NSThread sleepForTimeInterval:0.08];
                NSString *string = [NSString stringWithFormat:@"XLOperation2 %zd",i];
                NSLog(@"XLOperation2 -%zd -- isCanceled = %zd-- executing=%zd -- isFinished = %zd -- %@", i, self.isCancelled,self.executing,self.isFinished,[NSThread currentThread]);
            }
            if (self.isCancelled)
            {
                NSLog(@"22222self.isCancelled = yes , return");
                return;
            }
            for (NSInteger i = 0; i<100; i++) {
                [NSThread sleepForTimeInterval:0.05];
                NSString *string = [NSString stringWithFormat:@"XLOperation3 %zd",i];
                NSLog(@"XLOperation3 -%zd -- isCanceled = %zd-- executing=%zd -- isFinished = %zd -- %@", i, self.isCancelled,self.executing,self.isFinished,[NSThread currentThread]);
            }
            if (self.isCancelled)
            {
                NSLog(@"33333self.isCancelled = yes , return");
                return;
            }
        }
    }
    @catch (NSException *exception) {
        
    }
}

- (void)dealloc
{
    NSLog(@"dealloc XLOperation = %@ -- isCanceled = %zd-- executing=%zd -- isFinished = %zd -- %@",self, self.isCancelled,self.executing,self.isFinished,[NSThread currentThread]);
}
/*
 2017-07-04 11:38:49.711 Test - 多线程[14121:4211831] XLOperation1 -99 -- isCanceled = 1-- executing=1 -- isFinished = 0 -- <NSThread: 0x600000274280>{number = 3, name = (null)}
 2017-07-04 11:38:49.712 Test - 多线程[14121:4211831] 1111self.isCancelled = yes , return
 2017-07-04 11:38:49.712 Test - 多线程[14121:4211831] dealloc XLOperation = <XLOperation: 0x600000237600> -- isCanceled = 1-- executing=0 -- isFinished = 1 -- <NSThread: 0x600000274280>{number = 3, name = (null)}
 */

@end
