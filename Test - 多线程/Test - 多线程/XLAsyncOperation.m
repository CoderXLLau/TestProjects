//
//  XLAsyncOperation.m
//  Test - 多线程
//
//  Created by XL on 2017/7/5.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "XLAsyncOperation.h"

@interface XLAsyncOperation ()

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@end

@implementation XLAsyncOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)init
{
    if (self = [super init]) {
        NSLog(@"init - %@",[NSThread currentThread]);
        _executing = NO;
        _finished = NO;
    }
    return self;
}

- (void)start
{
    NSLog(@"start begin - %@",[NSThread currentThread]);
    if (self.isCancelled) {
        self.finished = YES;
        return;
    }
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    self.executing = YES;
    NSLog(@"start end - %@",[NSThread currentThread]);
}

- (void)main
{
    NSLog(@"main begin - %@",[NSThread currentThread]);
    @try {
        // 必须为自定义的 operation 提供 autorelease pool，因为 operation 完成后需要销毁。
        @autoreleasepool {
            // while 保证：只有当没有执行完成和没有被取消，才执行自定义的相应操作
            int i = 0;
            while ([self isCancelled] == NO && i < 10){
                sleep(2);  // 睡眠模拟耗时操作
                NSLog(@"i = %zd , currentThread = %@",i, [NSThread currentThread]);
                i++;
            }
            self.executing = NO;
            self.finished = YES;
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception %@", e);
    }
    NSLog(@"main end - %@",[NSThread currentThread]);
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

@end
