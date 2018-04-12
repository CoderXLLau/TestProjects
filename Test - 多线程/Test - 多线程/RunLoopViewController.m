//
//  ViewController.m
//  TestRunloop
//
//  Created by XL on 2017/6/5.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "RunLoopViewController.h"
#import "TestAddRunloopObserverViewController.h"

@interface RunLoopViewController ()

@property (nonatomic , weak) NSThread *thread;

@end

@implementation RunLoopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addTestButtonWithTitle:@"TestAddRunloopObserver" selector:@selector(TestAddRunloopObserver)];
    [self addTestButtonWithTitle:@"run1" selector:@selector(handleButtonClick:)];
    [self addTestButtonWithTitle:@"run2" selector:@selector(handleButtonClick:)];
    [self addTestButtonWithTitle:@"run3" selector:@selector(handleButtonClick:)];
    [self addTestButtonWithTitle:@"run4" selector:@selector(handleButtonClick:)];
    [self addTestButtonWithTitle:@"run5" selector:@selector(handleButtonClick:)];
    [self addTestButtonWithTitle:@"run6" selector:@selector(handleButtonClick:)];
    [self addTestButtonWithTitle:@"stopCurrentThread" selector:@selector(stopCurrentThread)];
    [self addTestButtonWithTitle:@"exitCurrentThread" selector:@selector(exitCurrentThread)];
    [self addTestButtonWithTitle:@"checkThreadIsAlived" selector:@selector(checkThreadIsAlived)];
}

#pragma mark -  buttonHandler method

- (void)TestAddRunloopObserver
{
    TestAddRunloopObserverViewController *tempVC = [[TestAddRunloopObserverViewController alloc] init];
    [self.navigationController pushViewController:tempVC animated:YES];
}

- (void)handleButtonClick:(UIButton *)button
{
    NSString *btnTitle = button.titleLabel.text;
    SEL tempSel = NSSelectorFromString(btnTitle);
    [self beginTestWithSelector:tempSel];
}

- (void)checkThreadIsAlived
{
    NSLog(@"%s----self.thread: %@--",__func__,self.thread);
    [self performSelector:@selector(testRunLoopIsAlived) onThread:self.thread withObject:nil waitUntilDone:NO];
}

/**
 可以发现， 针对run4 、5 方式创建的长活线程， 在调用stopCurrentThread方法后，仍然无法退出线程，调用checkThreadIsAlived方法依然可以有效输出
 */
- (void)stopCurrentThread
{
    [self performSelector:@selector(stopThread) onThread:self.thread withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
}

- (void)exitCurrentThread
{
    NSLog(@"%s----self.thread: %@--",__func__,self.thread);
    [self performSelector:@selector(exitThread) onThread:self.thread withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
}

#pragma mark -  test method

- (NSThread *)beginTestWithSelector:(SEL)selector
{
    NSThread *tempThread = [[NSThread alloc] initWithTarget:self selector:selector object:nil];
    self.thread = tempThread;
    tempThread.name = NSStringFromSelector(selector);
    [tempThread start];
    [tempThread runAtDealloc:^{
        NSLog(@"%@ 中的线程销毁",NSStringFromSelector(selector));
    }];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self performSelector:@selector(testRunLoopIsAlived) onThread:tempThread withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
//    });
    
    return tempThread;
}

/**
 如果线程中调用这个方法，打印后直接结束线程，再往这个线程中添加任务就不会执行了
 */
- (void) run1
{
    NSLog(@"run--输出这句线程就结束，点击屏幕往这个线程添加任务也不会执行了----%@--",[NSThread currentThread]);
}

/**
 如果调用这个线程，会一直卡在while循环，虽然不会结束线程，但是线程会卡在这里，后加入线程的任务不会被执行
 */
- (void)run2
{
    NSLog(@"%s--进入while循环--%@--",__func__,[NSThread currentThread]);
    while (1);//当前线程永远在这里执行
    NSLog(@"----------");
}

/**
 调用这个，会执行这句代码，虽然加入了一个RunLoop，但是RunLoop中没有东西，已进入RunLoop后就会推出RunLoop，也留不住线程[[NSRunLoop currentRunLoop] run];
 */
- (void)run3
{
    NSLog(@"%s----%@--",__func__,[NSThread currentThread]);
    [[NSRunLoop currentRunLoop] run];
    
    NSLog(@"------[NSRunLoop currentRunLoop].currentMode: %@",[NSRunLoop currentRunLoop].currentMode);
}

/**
 这种方法也可以保住线程，但是总是在进入RunLoop，然后退出，又进入，又退出，，，这样的方法虽然耗性能(频繁的进入退出会涉及到很多资源创建销毁, 例如自动释放池的频繁创建和销毁等)，但是可以继续在这个线程中处理其他的事件
 */
- (void)run4
{
    NSLog(@"%s----%@--",__func__,[NSThread currentThread]);
    while (1) {
        [[NSRunLoop currentRunLoop] run];
    }
    NSLog(@"-------");
}

/**
 这种方式可以保持线程长活,且优于run4的方式 , 这两种API保持的长活线程无法正常销毁,只能在适当的时候调用exit强制退出线程(退出之前注意释放CF的资源)
 */
- (void)run5
{
    NSLog(@"%s----%@--",__func__,[NSThread currentThread]);
    //2017-06-05 20:17:17.905 TestRunloop[10361:915052] -------currentMode = (null)
    NSLog(@"000-------currentMode = %@",[NSRunLoop currentRunLoop].currentMode);

    [self performSelector:@selector(testRunLoopIsAlived) withObject:nil afterDelay:1.5];
    //给RunLoop添加一个port源，这样RunLoop就不会推出
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
//    [[NSRunLoop currentRunLoop] run];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];// 这两个API : runUntilDate和run 都是在不停的调用runMode: beforeDate:,这两个API启动的runloop无法退出,这两种API保持的长活线程无法正常销毁,只能在适当的时候调用exit强制退出线程(退出之前注意释放CF的资源)
    
    // 调用run以后,不会执行之后的代码
    NSLog(@"111----调用run以后,不会执行之后的代码---currentMode = %@",[NSRunLoop currentRunLoop].currentMode);
}


/**
 这种方式是最优的保持线程存活方式, 随时可以退出线程, 不会有内存泄漏
 */
- (void)run6
{
    NSLog(@"%s----%@--",__func__,[NSThread currentThread]);

    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];//RunLoop中没有事件源、定时器等，进入RunLoop后就会立即推出RunLoop，留不住线程 ， 所以必须添加一个port源
    [self performSelector:@selector(testRunLoopIsAlived) withObject:nil afterDelay:1.5];
    while (![[NSThread currentThread] isCancelled]) {// 检查线程的isCancelled状态，如果线程状态被设置为canceled，就退出线程，否则就继续进入runloop，10s后退出runloop重新判断线程的最新状态
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];  //启动runloop ，10s后退出runloop
    }
    
    NSLog(@"222-------currentMode = %@",[NSRunLoop currentRunLoop].currentMode);
}

-(void)stopThread
{
    NSLog(@"begin -- %@ , %s",[NSThread currentThread],__func__);
    // 这个api 方法只会结束当前的 runMode:beforeDate: 调用，而不会结束后续的调用
    CFRunLoopStop(CFRunLoopGetCurrent());
    [[NSThread currentThread] cancel];
    NSLog(@"end -- %@ , %s",[NSThread currentThread],__func__);
}

/**
 强制退出当前线程, 注意:
 不要在主线程调用exit,否则闪退
 ARC模式下注意调用之前要释放CF资源 , MRC模式下都要释放
 线程退出,其后面的代码不会被执行d
 */
- (void)exitThread
{
    if (![NSThread currentThread].isMainThread && [NSThread currentThread].isCancelled) {
        // ARC中, 注意在此之前释放CF资源
        [NSThread exit];
    }
}

- (void)testLoopMode
{
    NSLog(@"----点击了屏幕----%@", [NSThread currentThread]);
    NSLog(@"444-------currentMode = %@",[NSRunLoop currentRunLoop].currentMode);
}

- (void)testRunLoopIsAlived
{
    NSLog(@"----testRunLoopIsAlive----%@", [NSThread currentThread]);
    NSLog(@"444-------currentMode = %@",[NSRunLoop currentRunLoop].currentMode);
}

- (void)timer{
    // 1. 创建定时器 : 使用该方法创建的定时器是不会添加到RunLoop中的
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerTest) userInfo:nil repeats:YES];
    
    // 指定Timer即可在scrollView滑动时出发定时器，但是这样在scrollview不滑动的情况下Timer就不会触发
    //NSDefaultRunLoopMode UITrackingRunLoopMode
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
}

- (void)timerTest {
    NSLog(@"run -------%@---%@",[NSThread currentThread],[NSRunLoop currentRunLoop].currentMode);
}

@end
