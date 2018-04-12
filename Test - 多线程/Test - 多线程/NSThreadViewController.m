//
//  NSThreadViewController.m
//  Test - 多线程
//
//  Created by XL on 2017/6/27.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "NSThreadViewController.h"
#import "XLThread.h"

@interface NSThreadViewController ()

@property (nonatomic , weak) NSThread *thread;

@end

@implementation NSThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTestButtonWithTitle:@"performTest" selector:@selector(performTest)];
    [self addTestButtonWithTitle:@"performTestWithRunloop" selector:@selector(performTestWithRunloop)];
    [self addTestButtonWithTitle:@"createThreadCancel" selector:@selector(createThreadCancel)];
    [self addTestButtonWithTitle:@"exitCurrentThread" selector:@selector(exitCurrentThread)];
}

#pragma mark    -   基本知识

- (void)createThread3
{
    [self performSelectorInBackground:@selector(run:) withObject:@"OC"];
}

- (void)createThread2
{
    [NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:@"XL"];
}

- (void)createThread1
{
    // 创建线程
    XLThread *thread = [[XLThread alloc] initWithTarget:self selector:@selector(run:) object:@"XL"];
    thread.name = @"my-thread";
    [thread start];// 启动线程
}

/**
 启动子线程时入口方法
 
 @param param 创建线程时的object
 */
- (void)run:(NSString *)param
{
    for (NSInteger i = 0; i<100; i++) {
        NSLog(@"-----run-----%@--%@", param, [NSThread currentThread]);
        if ([param isEqualToString:@"OC"]) {
            NSLog(@"--sleep 2s-----");
            [NSThread sleepForTimeInterval:2]; // 让线程睡眠2秒（阻塞2秒）
        } else {
            NSLog(@"--sleep 1s-----");
            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];// 让线程睡眠1秒（阻塞1秒）
        }
        if (i == 88) {
            [NSThread exit];// 退出线程
        }
    }
}

#pragma mark    -   cancel & exit

- (void)createThreadCancel
{
    XLThread *thread = [[XLThread alloc] initWithTarget:self selector:@selector(runCancel) object:@"XL"];
    self.thread = thread;
    thread.name = @"cancel-thread";
    [thread start];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"before thread.isCancelled = %zd",thread.isCancelled);
        [thread cancel];
        NSLog(@"after thread.isCancelled = %zd",thread.isCancelled);
    });
}

- (void)runCancel
{
    for (NSInteger i = 0; i<10000; i++) {
        NSLog(@"-----%zd , [NSThread currentThread] = %@", i , [NSThread currentThread]);
        sleep(0.01);
        if ([NSThread currentThread].isCancelled) {
            // 进行线程退出前的一些操作,如内存回收等
//            [NSThread exit]; // 线程退出,其后面的代码不会被执行d,在这里调用return一样可以退出任务
            return;
            NSLog(@"-----exit [NSThread currentThread] = %@" , [NSThread currentThread]);
        }
    }
}

- (void)exitCurrentThread
{
    NSLog(@"%s----self.thread: %@--",__func__,self.thread);
    [self performSelector:@selector(exitThread) onThread:self.thread withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
}

/**
 强制退出当前线程, 注意:
 不要在主线程调用exit,否则闪退
 ARC模式下注意调用之前要释放CF资源 , MRC模式下都要释放
 线程退出,其后面的代码不会被执行
 */
- (void)exitThread
{
    if (![NSThread currentThread].isMainThread && [NSThread currentThread].isCancelled) {
        // ARC中, 注意在此之前释放CF资源
        [NSThread exit];
    }
}

#pragma mark    -   线程间通信
#pragma mark    -   线程间通信 - 创建的线程中没有runloop
- (void)performTest
{
    XLThread *thread = [[XLThread alloc] initWithTarget:self selector:@selector(runPerform) object:@"XL"];
    thread.name = @"perform-thread";
    [thread start];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!thread) {
            NSLog(@"thread is null");
            return ;
        }
        NSLog(@"will handle performSelector %@",thread);
        
        // 如果设置waitUntilDone为YES，会闪退
        //        [self performSelector:@selector(runPerform2) onThread:thread withObject:nil waitUntilDone:YES];// 闪退
        //        NSLog(@"waitUntilDone:YES");
        
        //如果设置waitUntilDone为NO , thread会销毁
        [self performSelector:@selector(runPerform2) onThread:thread withObject:nil waitUntilDone:NO];//thread dealloc
        NSLog(@"waitUntilDone:NO");
    });
}

- (void)runPerform
{
    for (NSInteger i = 0; i<10; i++) {
        NSLog(@"---runPerform--%zd , [NSThread currentThread] = %@", i , [NSThread currentThread]);
    }
}

- (void)runPerform2
{
    for (NSInteger i = 0; i<100; i++) {
        NSLog(@"---runPerform2 --%zd , [NSThread currentThread] = %@", i , [NSThread currentThread]);
    }
}

//- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait modes:(nullable NSArray<NSString *> *)array;
//- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait;
//// equivalent to the first method with kCFRunLoopCommonModes
//
//- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait modes:(nullable NSArray<NSString *> *)array NS_AVAILABLE(10_5, 2_0);
//- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait NS_AVAILABLE(10_5, 2_0);
//// equivalent to the first method with kCFRunLoopCommonModes
#pragma mark    -   线程间通信 - 创建的线程中有runloop
- (void)performTestWithRunloop
{
    XLThread *thread = [[XLThread alloc] initWithTarget:self selector:@selector(runPerformWithRunloop) object:@"XL"];
    thread.name = @"runloop-thread";
    [thread start];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!thread) {
            NSLog(@"thread is null");
            return ;
        }
        
        NSLog(@"will handle performSelector %@",thread);
        [self performSelector:@selector(runPerform2) onThread:thread withObject:nil waitUntilDone:YES]; //waitUntilDone:YES,当前线程会等待thread执行完runPerform2后才继续往下执行
        NSLog(@"waitUntilDone:YES");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"thread will handle cancel");
            [thread cancel]; // 标记变成状态为cancel,下面的while判断到线程取消时,不会再次进入runloop,线程会退出并销毁
        });
    });
}

- (void)runPerformWithRunloop {
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];//RunLoop中没有事件源、定时器等，进入RunLoop后就会立即推出RunLoop，留不住线程 ， 所以必须添加一个port源
    while (![[NSThread currentThread] isCancelled]) {// 检查线程的isCancelled状态，如果线程状态被设置为canceled，就退出线程，否则就继续进入runloop，10s后退出runloop重新判断线程的最新状态
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];  //启动runloop ，10s后退出runloop
    }
}


@end
