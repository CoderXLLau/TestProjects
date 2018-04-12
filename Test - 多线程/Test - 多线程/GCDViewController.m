//
//  GCDViewController.m
//  Test - 多线程
//
//  Created by XL on 2017/6/28.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "GCDViewController.h"
#import "TestPreLoadViewController.h"
#import <pthread.h>

@interface GCDViewController ()
{
    dispatch_queue_t _serialQueue;
    UINavigationController *_navController;
}
@property (nonatomic , strong)UIImageView  *imageView;
@property (nonatomic , strong)dispatch_source_t timer;
@property (nonatomic , strong)TestPreLoadViewController *viewController;

@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addTestButtonWithTitle:@"syncMain" selector:@selector(syncMain)];
    [self addTestButtonWithTitle:@"asyncMain" selector:@selector(asyncMain)];
    [self addTestButtonWithTitle:@"syncSerial" selector:@selector(syncSerial)];
    [self addTestButtonWithTitle:@"asyncSerial" selector:@selector(asyncSerial)];
    [self addTestButtonWithTitle:@"syncConcurrent" selector:@selector(syncConcurrent)];
    [self addTestButtonWithTitle:@"asyncConcurrent" selector:@selector(asyncConcurrent)];
    [self addTestButtonWithTitle:@"downloadImage" selector:@selector(downloadImage)];
    [self addTestButtonWithTitle:@"asyncConcurrentWithSyncSerial" selector:@selector(asyncConcurrentWithSyncSerial)];
    [self addTestButtonWithTitle:@"asyncConcurrentWithSyncMain" selector:@selector(asyncConcurrentWithSyncMain)];
    [self addTestButtonWithTitle:@"dispatchGroup" selector:@selector(dispatchGroup)];
    [self addTestButtonWithTitle:@"groupWithEnterLeave" selector:@selector(groupWithEnterLeave)];
    [self addTestButtonWithTitle:@"dispatch_apply" selector:@selector(apply)];
    [self addTestButtonWithTitle:@"dispatch_apply_f" selector:@selector(applyF)];
    [self addTestButtonWithTitle:@"dispatch_once" selector:@selector(once)];
    [self addTestButtonWithTitle:@"testsuplend" selector:@selector(testsuplend)];
    [self addTestButtonWithTitle:@"testsuplend2" selector:@selector(testsuplend2)];
    [self addTestButtonWithTitle:@"testsuplend2_点击挂起" selector:@selector(suspend)];
    [self addTestButtonWithTitle:@"resume2" selector:@selector(resume)];
    
    [self addTestButtonWithTitle:@"dispatch_barrier_sync" selector:@selector(barrierSync)];
    [self addTestButtonWithTitle:@"dispatch_barrier_async" selector:@selector(barrierAsync)];

    [self addTestButtonWithTitle:@"cancelDispatchTimer" selector:@selector(cancelDispatchTimer)];
    [self addTestButtonWithTitle:@"dispatchSourceCustomEvent" selector:@selector(dispatchSourceCustomEvent)];
    
    [self addTestButtonWithTitle:@"dispatch_semaphore" selector:@selector(dispatchSemaphore)];
    [self addTestButtonWithTitle:@"gcdConcurrentOperationCount" selector:@selector(gcdConcurrentOperationCount)];
    
    [self addTestButtonWithTitle:@"prepareViewControllerAndJumpTo" selector:@selector(prepareViewControllerAndJumpTo)];
    
    [self addTestButtonWithTitle:@"gcdCancelCustom" selector:@selector(gcdCancelCustom)];
    [self addTestButtonWithTitle:@"gcdBlockCancel" selector:@selector(gcdBlockCancel)];
    
    [self addTestButtonWithTitle:@"testSyncAndAsync" selector:@selector(testSyncAndAsync)];
    [self addTestButtonWithTitle:@"testdispatch_barrier_async" selector:@selector(testdispatch_barrier_async)];
    
    [self addTestButtonWithTitle:@"testTargetQueue" selector:@selector(testTargetQueue)];
    [self addTestButtonWithTitle:@"testTargetQueuePriority" selector:@selector(testTargetQueuePriority)];
    [self addTestButtonWithTitle:@"testTargetConcurrentQueue" selector:@selector(testTargetConcurrentQueue)];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 100, 100)];
    self.imageView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.imageView];
}

- (void)dealloc
{
    NSLog(@"dealloc ----- self.timer = %@",self.timer);
}

#pragma mark    -   测试sync/async 分别和 串行队列/并行队列/主队列 结合使用创建线程的情况

/**
 * 同步函数 + 主队列：不会创建新的线程,添加任务到主队列并顺序执行,添加的任务被要求在线程中立即执行,所以如果在主线程中使用此方式会造成死锁(新添加的任务要求立即执行,但是主线程正在执行添加任务的任务,两个会互相等待,造成死锁)
 */
- (void)syncMain
{
    NSLog(@"syncMain ----- begin");
    
    // 2.将任务加入队列
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"---run1--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"syncMain ----- add one block");
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"---run2--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"syncMain ----- add two block");
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"---run3--%d---%@",i,[NSThread currentThread]);
        }
    });
    
    NSLog(@"syncMain ----- end");
}

/**
 * 异步函数 + 主队列：不开启新线程,只在主线程中按顺序执行任务
 */
- (void)asyncMain
{
    NSLog(@"-------asyncMain begin");
    // 1.获得主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 2.将任务加入队列
    dispatch_async(queue, ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"---run1--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"-------asyncMain add one block");
    dispatch_async(queue, ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"---run2--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"-------asyncMain add two block");
    dispatch_async(queue, ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"---run3--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"-------asyncMain end");
/*
 2017-06-28 18:40:07.557 Test - 多线程[9017:346027] -------asyncMain add one block
 2017-06-28 18:40:07.558 Test - 多线程[9017:346027] -------asyncMain add two block
 2017-06-28 18:40:07.558 Test - 多线程[9017:346027] -------asyncMain end
 2017-06-28 18:40:07.558 Test - 多线程[9017:346027] ---run1--0---<NSThread: 0x60800006cbc0>{number = 1, name = main}
 2017-06-28 18:40:07.559 Test - 多线程[9017:346027] ---run1--1---<NSThread: 0x60800006cbc0>{number = 1, name = main}
 */
}

/**
 * 同步函数 + 串行队列：不会开启新的线程，在当前线程执行任务。任务是串行的，执行完一个任务，再执行下一个任务
    添加任务并执行完毕后才会继续往下面添加任务
 */
- (void)syncSerial
{
    NSLog(@"-------syncSerial begin");
    // 1.创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("com.testGCD.queue", DISPATCH_QUEUE_SERIAL);
    
    // 2.将任务加入队列
    dispatch_sync(queue, ^{
        sleep(2);
        NSLog(@"---run1-----%@",[NSThread currentThread]);
    });
    NSLog(@"---------syncSerial add one block ");

    dispatch_sync(queue, ^{
        sleep(2);
        NSLog(@"---run2-----%@",[NSThread currentThread]);
    });
    NSLog(@"---------syncSerial add two block ");
    dispatch_sync(queue, ^{
        sleep(2);
        for (int i = 0; i<100; i++) {
            NSLog(@"---run3--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"syncSerial end  ");
    /*
     2018-03-30 15:51:35.067340+0800 Test - 多线程[27156:6644038] -------syncSerial begin
     2018-03-30 15:51:37.068853+0800 Test - 多线程[27156:6644038] ---run1-----<NSThread: 0x604000075540>{number = 1, name = main}
     2018-03-30 15:51:37.069071+0800 Test - 多线程[27156:6644038] ---------syncSerial add one block
     2018-03-30 15:51:39.069874+0800 Test - 多线程[27156:6644038] ---run2-----<NSThread: 0x604000075540>{number = 1, name = main}
     2018-03-30 15:51:39.070015+0800 Test - 多线程[27156:6644038] ---------syncSerial add two block
     2018-03-30 15:51:41.071206+0800 Test - 多线程[27156:6644038] ---run3--0---<NSThread: 0x604000075540>{number = 1, name = main}
     */
}

/**
 * 异步函数 + 串行队列：会开启一条新的线程，在新创建的线程中任务是串行的，执行完一个任务，再执行下一个任务
 */
- (void)asyncSerial
{
    NSLog(@"---------asyncSerial  begin ");

    // 1.创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("com.testGCD.queue", DISPATCH_QUEUE_SERIAL);
    //    dispatch_queue_t queue = dispatch_queue_create("com.testGCD.queue", NULL);
    
    // 2.将任务加入队列
    dispatch_async(queue, ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"---run1--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"---------asyncSerial  add one block ");

    dispatch_async(queue, ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"---run2--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"---------asyncSerial  add two block ");
    dispatch_async(queue, ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"---run3--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"---------asyncSerial  end ");
}

/**
 * 同步函数 + 并发队列：不会开启新的线程,任务在当前线程按顺序执行
 */
- (void)syncConcurrent
{
    NSLog(@"syncConcurrent--------begin");
    // 1.获得全局的并发队列
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue = dispatch_queue_create("com.testGCD.DISPATCH_QUEUE_CONCURRENT", DISPATCH_QUEUE_CONCURRENT);

    // 2.将任务加入队列
    dispatch_sync(queue, ^{
        sleep(3);
        for (int i = 0; i<100; i++) {
            NSLog(@"---run1--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"syncConcurrent--------add one block");
    dispatch_sync(queue, ^{
        sleep(2);
        for (int i = 0; i<100; i++) {
            NSLog(@"---run2--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"syncConcurrent--------add two block");
    dispatch_sync(queue, ^{
        sleep(1);
        for (int i = 0; i<100; i++) {
            NSLog(@"---run3--%d---%@",i,[NSThread currentThread]);
        }
    });
    
    NSLog(@"syncConcurrent--------end");
}

/**
 * 异步函数 + 并发队列：可以同时开启多条线程,任务是并发执行的
 */
- (void)asyncConcurrent
{
    NSLog(@"asyncConcurrent--------begin");
    // 1.创建一个并发队列
    // label : 相当于队列的名字
        dispatch_queue_t queue = dispatch_queue_create("com.testGCD.queue", DISPATCH_QUEUE_CONCURRENT);
    
    // 1.获得全局的并发队列
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 2.将任务加入队列
    dispatch_async(queue, ^{
        for (int i = 0; i<1000; i++) {
            NSLog(@"---run1--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"asyncConcurrent--------add one block");
    dispatch_async(queue, ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"---run2--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"asyncConcurrent--------add two block");
    dispatch_async(queue, ^{
        for (int i = 0; i<100; i++) {
            NSLog(@"---run3--%d---%@",i,[NSThread currentThread]);
        }
    });
    
    NSLog(@"asyncConcurrent--------end");
    //    dispatch_release(queue); // iOS6以后的版本,不需要我们管理内存,ARC可以管理GCD对象
}


/**
 会在新创建的线程中执行SyncSerial方法
 */
- (void)asyncConcurrentWithSyncSerial
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i<10; i++) {
            NSLog(@"---asyncConcurrentWithSyncSerial--%d---%@",i,[NSThread currentThread]);
            [self syncSerial];
        }
    });
}

/**
 新创建的线程中,调用syncMain,会调到主线程执行syncMain中的任务
 */
- (void)asyncConcurrentWithSyncMain
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i<10; i++) {
            NSLog(@"---asyncConcurrentWithSyncSerial--%d---%@",i,[NSThread currentThread]);
            [self syncMain];
        }
    });
}

#pragma mark    -   GCD中线程间通信

/**
 子线程下载图片,下载完毕后,合成图片后传递到主线程做UI显示
 */
- (void)downloadImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:@"http://img.pconline.com.cn/images/photoblog/9/9/8/1/9981681/200910/11/1255259355826.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
        });
    });
}

#pragma mark    -   队列组,两种

- (void)dispatchGroup
{
    NSLog(@"---group-begin---%@",[NSThread currentThread]);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{// 异步添加任务到全局并发队列,并关联到调度组
        for (int i = 0; i<2; i++) {
            NSLog(@"---group1--%d---%@",i,[NSThread currentThread]);
        }
    });
    dispatch_group_async(group, dispatch_get_main_queue(), ^{// 异步添加任务到主队列,并关联到调度组
        for (int i = 0; i<2; i++) {
            NSLog(@"---group2--%d---%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"---group middle %@",[NSThread currentThread]);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{ // group中的任务都执行完毕后，才回执行这个block
        NSLog(@"---dispatch_group_notify---%@",[NSThread currentThread]);
        dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
            NSLog(@"---group3-----%@",[NSThread currentThread]);
        });
        NSLog(@"---dispatch_group_notify middle %@",[NSThread currentThread]);
        dispatch_group_async(group, dispatch_get_main_queue(), ^{
            NSLog(@"---group4----%@",[NSThread currentThread]);
        });
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSLog(@"---second dispatch_group_notify---%@",[NSThread currentThread]);
        });
    });
    NSLog(@"---before dispatch_group_wait %@",[NSThread currentThread]);
    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC)); // 同步函数，会阻塞当前线程，只要超时或者group任务完成，返回0表示任务完全执行完毕，非0表示超时 , 如果想要一只等待,可以设置第二个参数为:DISPATCH_TIME_FOREVER
    NSLog(@"---group-end---%@",[NSThread currentThread]);
    
    /*
     2017-06-29 10:38:15.572 Test - 多线程[21587:754475] ---group-begin---<NSThread: 0x60000007d200>{number = 1, name = main}
     2017-06-29 10:38:15.573 Test - 多线程[21587:754568] ---group1--0---<NSThread: 0x6000002742c0>{number = 3, name = (null)}
     2017-06-29 10:38:15.573 Test - 多线程[21587:754475] ---group middle <NSThread: 0x60000007d200>{number = 1, name = main}  //①
     2017-06-29 10:38:15.573 Test - 多线程[21587:754568] ---group1--1---<NSThread: 0x6000002742c0>{number = 3, name = (null)}  //②
     2017-06-29 10:38:15.573 Test - 多线程[21587:754475] ---before dispatch_group_wait <NSThread: 0x60000007d200>{number = 1, name = main} //③
     2017-06-29 10:38:20.575 Test - 多线程[21587:754475] ---group-end---<NSThread: 0x60000007d200>{number = 1, name = main} //④
     2017-06-29 10:38:20.576 Test - 多线程[21587:754475] ---group2--0---<NSThread: 0x60000007d200>{number = 1, name = main}
     2017-06-29 10:38:20.576 Test - 多线程[21587:754475] ---group2--1---<NSThread: 0x60000007d200>{number = 1, name = main} //⑤
     2017-06-29 10:38:20.577 Test - 多线程[21587:754475] ---dispatch_group_notify---<NSThread: 0x60000007d200>{number = 1, name = main} //⑥
     2017-06-29 10:38:20.577 Test - 多线程[21587:754475] ---dispatch_group_notify middle <NSThread: 0x60000007d200>{number = 1, name = main}
     2017-06-29 10:38:20.577 Test - 多线程[21587:754568] ---group3-----<NSThread: 0x6000002742c0>{number = 3, name = (null)}
     2017-06-29 10:38:20.578 Test - 多线程[21587:754475] ---group4----<NSThread: 0x60000007d200>{number = 1, name = main}
     2017-06-29 10:38:20.578 Test - 多线程[21587:754475] ---second dispatch_group_notify---<NSThread: 0x60000007d200>{number = 1, name = main} //⑦

     */
}

- (void)groupWithEnterLeave
{
    NSLog(@"---group-begin---%@",[NSThread currentThread]);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);// Manually indicate a block has entered the group
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(3);
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2);
        dispatch_group_leave(group);
    });

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"group任务执行完毕");
    });
    NSLog(@"---group-end---%@",[NSThread currentThread]);
}

#pragma mark    -   栅栏

- (void)barrierAsync
{
    NSLog(@"barrierAsync begin");
    dispatch_queue_t queue = dispatch_queue_create("12312312", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"----1-----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"----2-----%@", [NSThread currentThread]);
    });
    NSLog(@"before dispatch_barrier_async");
    dispatch_barrier_async(queue, ^{
        NSLog(@"----barrier-----%@", [NSThread currentThread]);
    });
    NSLog(@"after dispatch_barrier_async");
    
    dispatch_async(queue, ^{
        NSLog(@"----3-----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"----4-----%@", [NSThread currentThread]);
    });
    NSLog(@"barrierAsync end");
    /*
     2017-06-29 12:29:32.048 Test - 多线程[22813:835755] barrierAsync begin //①
     2017-06-29 12:29:32.049 Test - 多线程[22813:835755] before dispatch_barrier_async //②
     2017-06-29 12:29:32.049 Test - 多线程[22813:835815] ----1-----<NSThread: 0x600000268e00>{number = 5, name = (null)} //③
     2017-06-29 12:29:32.049 Test - 多线程[22813:837436] ----2-----<NSThread: 0x600000267540>{number = 6, name = (null)} //④
     2017-06-29 12:29:32.049 Test - 多线程[22813:835755] after dispatch_barrier_async //⑤
     2017-06-29 12:29:32.049 Test - 多线程[22813:837436] ----barrier-----<NSThread: 0x600000267540>{number = 6, name = (null)} //⑥
     2017-06-29 12:29:32.049 Test - 多线程[22813:835755] barrierAsync end //⑦
     2017-06-29 12:29:32.050 Test - 多线程[22813:837436] ----3-----<NSThread: 0x600000267540>{number = 6, name = (null)} //⑧
     2017-06-29 12:29:32.050 Test - 多线程[22813:835815] ----4-----<NSThread: 0x600000268e00>{number = 5, name = (null)} //⑨
     */
}


/**
 sync, 同步函数,会阻塞当前线程添加任务,直到添加的任务执行完毕才会继续往下执行, 所以after dispatch_barrier_sync会一直等到----barrier-----打印后才打印
 
 */
- (void)barrierSync
{
    NSLog(@"barrierSync begin");
    dispatch_queue_t queue = dispatch_queue_create("12312312", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"----1-----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"----2-----%@", [NSThread currentThread]);
    });
    NSLog(@"before dispatch_barrier_sync");
    dispatch_barrier_sync(queue, ^{
        NSLog(@"----barrier-----%@", [NSThread currentThread]);
    });
    NSLog(@"after dispatch_barrier_sync");

    dispatch_async(queue, ^{
        NSLog(@"----3-----%@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"----4-----%@", [NSThread currentThread]);
    });
    NSLog(@"barrierSync end");
    
    /*
     2017-06-29 12:28:15.355 Test - 多线程[22813:835755] barrierSync begin //①
     2017-06-29 12:28:15.355 Test - 多线程[22813:835755] before dispatch_barrier_sync //②
     2017-06-29 12:28:15.355 Test - 多线程[22813:835803] ----2-----<NSThread: 0x6000002692c0>{number = 4, name = (null)} //③
     2017-06-29 12:28:15.355 Test - 多线程[22813:835805] ----1-----<NSThread: 0x608000260bc0>{number = 3, name = (null)} //④
     2017-06-29 12:28:15.356 Test - 多线程[22813:835755] ----barrier-----<NSThread: 0x600000071880>{number = 1, name = main} //⑤
     2017-06-29 12:28:15.356 Test - 多线程[22813:835755] after dispatch_barrier_sync //⑥
     2017-06-29 12:28:15.356 Test - 多线程[22813:835755] barrierSync end //⑦
     2017-06-29 12:28:15.356 Test - 多线程[22813:835805] ----3-----<NSThread: 0x608000260bc0>{number = 3, name = (null)} //⑧
     2017-06-29 12:28:15.356 Test - 多线程[22813:835803] ----4-----<NSThread: 0x6000002692c0>{number = 4, name = (null)} //⑨
     */
}

#pragma mark    -   迭代

/**
 * 快速迭代
 */
- (void)apply
{
    NSLog(@"apply begin");
    dispatch_apply(4, dispatch_get_global_queue(0, 0), ^(size_t index) {
        NSLog(@"index = %zd , thread = %@",index,[NSThread currentThread]);
    });
    NSLog(@"apply end");
}

- (void)applyF
{
    dispatch_apply_f(10, dispatch_get_global_queue(0, 0), NULL, one);
}

void one(void * context, size_t index)
{
    NSLog(@"index = %zd",index);
}

- (void)applyMoveFile
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSString *from = @"/Users/XL/Desktop/From";
    NSString *to = @"/Users/XL/Desktop/To";
    
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *subpaths = [mgr subpathsAtPath:from];
    
    dispatch_apply(subpaths.count, queue, ^(size_t index) {
        NSString *subpath = subpaths[index];
        NSString *fromFullpath = [from stringByAppendingPathComponent:subpath];
        NSString *toFullpath = [to stringByAppendingPathComponent:subpath];
        // 剪切
        [mgr moveItemAtPath:fromFullpath toPath:toFullpath error:nil];
        
        NSLog(@"index =%zd  %@ subpath = %@",index, [NSThread currentThread], subpath);
    });
}

/**
 * 传统文件剪切
 */
- (void)moveFile
{
    NSString *from = @"/Users/XL/Desktop/From";
    NSString *to = @"/Users/XL/Desktop/To";
    
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *subpaths = [mgr subpathsAtPath:from];
    
    for (NSString *subpath in subpaths) {
        NSString *fromFullpath = [from stringByAppendingPathComponent:subpath];
        NSString *toFullpath = [to stringByAppendingPathComponent:subpath];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 剪切
            [mgr moveItemAtPath:fromFullpath toPath:toFullpath error:nil];
        });
    }
}

#pragma mark    -   dispatch_once

/**
 dispatch_once使用案例
 http://www.dreamingwish.com/article/gcd-guide-dispatch-once-1.html dispatch_once的深度解析
 */
- (void)once
{
    dispatch_apply(3, dispatch_get_global_queue(0, 0), ^(size_t index) {
        double beforeTime = CFAbsoluteTimeGetCurrent();
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"------run");
        });
        double afterTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"------index = %zd ,beforeTime = %f, after time = %f ,interval = %f",index,beforeTime,afterTime,afterTime - beforeTime);

     });
    
    int a = 10;
    double beforeIf = CFAbsoluteTimeGetCurrent();
    if ( a < 11) {
        
    }
    double afterIf = CFAbsoluteTimeGetCurrent();
    NSLog(@"----- beforeIf = %f, afterIf = %f ,interval = %f",beforeIf,afterIf,afterIf - beforeIf);
}


/**
 线程锁重实现dispatch_once , 后续调用负载 30+ns

 @param predicate <#predicate description#>
 @param block <#block description#>
 */
void DWDispatchOncePthread_mutex_t(dispatch_once_t *predicate, dispatch_block_t block) {
    static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&mutex);
    if(!*predicate) {
        block();
        *predicate = 1;
    }
    pthread_mutex_unlock(&mutex);
}

/**
 自旋锁重实现dispatch_once , 后续调用负载 6.5ns

 @param predicate <#predicate description#>
 @param block <#block description#>
 */
//void DWDispatchOnceOSSpinLockLock(dispatch_once_t *predicate, dispatch_block_t block) {
//    static OSSpinLock lock = OS_SPINLOCK_INIT;
//    OSSpinLockLock(&lock);
//    if(!*predicate) {
//        block();
//        *predicate = 1;
//    }
//    OSSpinLockUnlock(&lock);
//}

//
void DWDispatchOnce(dispatch_once_t *predicate, dispatch_block_t block)
{
    if(*predicate == 2)
    {
        __sync_synchronize();
        return;
    }
    
    volatile dispatch_once_t *volatilePredicate = predicate;
    
    if(__sync_bool_compare_and_swap(volatilePredicate, 0, 1)) {
        block();
        __sync_synchronize();
        *volatilePredicate = 2;
    } else {
        while(*volatilePredicate != 2)
            ;//注意这里没有循环体
        __sync_synchronize();
    }
}

#pragma mark    -   延迟,以及和其他区别

/**
 * 延迟执行
 */
- (void)delay
{
    NSLog(@"touchesBegan-----");
    //    [self performSelector:@selector(run) withObject:nil afterDelay:2.0];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"run-----"); // 延迟2秒后提交任务
    });
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:NO];
}

- (void)run
{
    NSLog(@"run-----");
}

#pragma mark    -   内存管理

#pragma mark    -   挂起线程
#pragma mark    -   挂起线程 测试1

- (void)testsuplend
{
    //test1
    //    dispatch_queue_t queue = dispatch_get_global_queue(0, 0); // dispatch_suspend对全局并发队列无效
    //test2
    //    dispatch_queue_t queue = dispatch_queue_create(NULL, 0); // dispatch_suspend 对串行队列有效
    //test3
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT); // dispatch_suspend 对自己创建的并发队列有效
    dispatch_async(queue, ^{
        for (int i = 0 ; i < 10; i ++) {
            NSLog(@"---suplend1 -- %zd thread = %@",i,[NSThread currentThread]);
            sleep(1);
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"dispatch_suspend queue one , suplend1打印任务执行完毕后会挂起队列，直到dispatch_resume调用后恢复队列");
        dispatch_suspend(queue);
    });
    
    // 4s后继续添加新的任务，如果在添加之前点击挂起，此任务不会执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(queue, ^{
            for (int i = 0 ; i < 10; i ++) {
                sleep(2);
                NSLog(@"---suplend2 -- %zd thread = %@",i,[NSThread currentThread]);
            }
        });
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"dispatch_resume queue one ,---suplend2 --打印任务会恢复执行");
        dispatch_resume(queue);
    });
    /*
     2017-06-29 23:31:56.678 Test - 多线程[57328:8371175] ---suplend1 -- 0 thread = <NSThread: 0x60000027b740>{number = 3, name = (null)}
     2017-06-29 23:31:57.680 Test - 多线程[57328:8371175] ---suplend1 -- 1 thread = <NSThread: 0x60000027b740>{number = 3, name = (null)}
     2017-06-29 23:31:58.682 Test - 多线程[57328:8371175] ---suplend1 -- 2 thread = <NSThread: 0x60000027b740>{number = 3, name = (null)}
     2017-06-29 23:31:58.777 Test - 多线程[57328:8371126] dispatch_suspend queue one , suplend1打印任务执行完毕后会挂起队列，直到dispatch_resume调用后恢复队列 //①
     2017-06-29 23:31:59.687 Test - 多线程[57328:8371175] ---suplend1 -- 3 thread = <NSThread: 0x60000027b740>{number = 3, name = (null)}//②
     2017-06-29 23:32:00.689 Test - 多线程[57328:8371175] ---suplend1 -- 4 thread = <NSThread: 0x60000027b740>{number = 3, name = (null)}
     2017-06-29 23:32:01.690 Test - 多线程[57328:8371175] ---suplend1 -- 5 thread = <NSThread: 0x60000027b740>{number = 3, name = (null)}
     2017-06-29 23:32:02.677 Test - 多线程[57328:8371126] dispatch_resume queue one ,---suplend2 --打印任务会恢复执行//③
     2017-06-29 23:32:02.692 Test - 多线程[57328:8371175] ---suplend1 -- 6 thread = <NSThread: 0x60000027b740>{number = 3, name = (null)}
     2017-06-29 23:32:03.695 Test - 多线程[57328:8371175] ---suplend1 -- 7 thread = <NSThread: 0x60000027b740>{number = 3, name = (null)}//④
     2017-06-29 23:32:04.682 Test - 多线程[57328:8371177] ---suplend2 -- 0 thread = <NSThread: 0x60000027b7c0>{number = 4, name = (null)}//⑤
     2017-06-29 23:32:04.699 Test - 多线程[57328:8371175] ---suplend1 -- 8 thread = <NSThread: 0x60000027b740>{number = 3, name = (null)}
     2017-06-29 23:32:05.702 Test - 多线程[57328:8371175] ---suplend1 -- 9 thread = <NSThread: 0x60000027b740>{number = 3, name = (null)}
     */
}
#pragma mark    -   挂起线程 测试2

static dispatch_queue_t _queue;
- (void)testsuplend2
{
    //test1
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0); // dispatch_suspend对全局并发队列无效
    //test2
//    dispatch_queue_t queue = dispatch_queue_create(NULL, 0); // dispatch_suspend 对串行队列有效
    //test3
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT); // dispatch_suspend 对串行队列有效
    
    _queue = queue;
    dispatch_async(queue, ^{
        for (int i = 0 ; i < 10; i ++) {
            NSLog(@"---suplend1 -- %zd thread = %@",i,[NSThread currentThread]);
            sleep(2);
        }
    });
    
    // 4s后继续添加新的任务，如果在添加之前点击挂起，此任务不会执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(queue, ^{
            for (int i = 0 ; i < 10; i ++) {
                sleep(2);
                NSLog(@"---suplend2 -- %zd thread = %@",i,[NSThread currentThread]);
            }
        });
    });
}

- (void)suspend
{
    NSLog(@"suspend queue");
    dispatch_suspend(_queue);// 挂起队列
}

- (void)resume
{
    NSLog(@"resume queue");
    dispatch_resume(_queue);
}

#pragma mark    -   dispatch_source
#pragma mark    -   dispatch_source DISPATCH_SOURCE_TYPE_DATA_ADD

- (void)dispatchSourceCustomEvent
{
    dispatch_source_t  source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(source, ^{
        NSLog(@"%lu 人已报名",dispatch_source_get_data(source));
    });
    dispatch_resume(source);
    dispatch_apply(5, dispatch_get_global_queue(0, 0), ^(size_t index) {
        NSLog(@"用户%zd 报名郊游",index);
        dispatch_source_merge_data(source, 1); // 触发事件,传递数据
    });
}

#pragma mark    -   dispatch_source     DISPATCH_SOURCE_TYPE_TIMER 

/**
 定时器
 */
- (void)dispatchTimer
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    _timer = timer;
    //NSEC_PER_SEC宏其定义是1000000000纳秒,也就是1秒
    dispatch_source_set_timer(timer, dispatch_walltime(0,1 * NSEC_PER_SEC), 1ull * NSEC_PER_SEC, 0);
    DISPATCH_TIME_NOW;DISPATCH_TIME_FOREVER;
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"-----handle dispatchTimer thread = %@",[NSThread currentThread]);
    });
    dispatch_source_set_cancel_handler(timer, ^{
        NSLog(@"-----cancel dispatchTimer thread = %@",[NSThread currentThread]);
    });
    dispatch_resume(timer);//启动定时器
}

- (void)cancelDispatchTimer
{
    @synchronized (self.timer) {
        if (self.timer) {
            dispatch_source_cancel(self.timer); // timer为null时会闪退
        }
    }
}

#pragma mark    -   dispatch_semaphore

-(void)dispatchSemaphore{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    NSMutableArray *users = [NSMutableArray array];
    for (int i = 0; i < 300; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            // 访问共有资源的任务代码
            NSLog(@"i = %zd , 添加一个用户,thread = %@",i,[NSThread currentThread]);
            [users addObject:@(i)];
            dispatch_semaphore_signal(semaphore);
        });
    }
    /*
     //不实用信号量控制 , 从0到299用时0.035s
     2017-07-03 14:22:45.360 Test - 多线程[92687:3508000] i = 0 , 删除一个用户 ,thread = <NSThread: 0x60000007de80>{number = 3, name = (null)}
     2017-07-03 14:22:45.395 Test - 多线程[92687:3508177] i = 299 , 添加一个用户,thread = <NSThread: 0x608000269540>{number = 33, name = (null)}

     // 使用信号量控制 , 从0到299用时0.082s
     2017-07-03 14:23:46.540 Test - 多线程[92713:3509186] i = 0 , 删除一个用户 ,thread = <NSThread: 0x6000002675c0>{number = 3, name = (null)}
     2017-07-03 14:23:46.622 Test - 多线程[92713:3509395] i = 299 , 添加一个用户,thread = <NSThread: 0x60000026c1c0>{number = 59, name = (null)}
     */
}

/**
 GCD控制并发数量
 */
- (void)gcdConcurrentOperationCount
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"semaphore = %@",semaphore);
        });
        for (int i = 0; i < 100; i++)
        {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_async(queue, ^{
                sleep(2);
                NSLog(@"结束任务i = %d , thread = %@",i,[NSThread currentThread]);
                dispatch_semaphore_signal(semaphore);
            });
        }
    });
}

#pragma mark    -   dispatch_set_target_queue

/**
 同步队列
 一般都是把一个任务放到一个串行的queue中，如果这个任务被拆分了，被放置到多个串行的queue中，但实际还是需要这个任务同步执行，那么就会有问题，因为多个串行queue之间是并行的。这时候dispatch_set_target_queue将起到作用。
 
 在必须将不可并行执行的处理追加到多个Serial Dispatch Queue中时，如果使用dispatch_set_target_queue函数将目标指定为某一个Serial Dispatch Queue，即可防止处理并行执行
 */
- (void)testTargetQueue {
    dispatch_queue_t targetQueue = dispatch_queue_create("test.target.queue", DISPATCH_QUEUE_SERIAL);

    dispatch_queue_t queue1 = dispatch_queue_create("test.1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("test.2", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue3 = dispatch_queue_create("test.3", DISPATCH_QUEUE_SERIAL);
    
    dispatch_set_target_queue(queue1, targetQueue);
    dispatch_set_target_queue(queue2, targetQueue);
    dispatch_set_target_queue(queue3, targetQueue);
    
    dispatch_async(queue1, ^{
        NSLog(@"1 in");
        [NSThread sleepForTimeInterval:3.f];
        NSLog(@"1 out");
    });
    dispatch_async(queue2, ^{
        NSLog(@"2 in");
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"2 out");
    });
    dispatch_async(queue3, ^{
        NSLog(@"3 in");
        [NSThread sleepForTimeInterval:1.f];
        NSLog(@"3 out");
    });
}

- (void)testTargetConcurrentQueue {
    dispatch_queue_t targetQueue = dispatch_queue_create("test.target.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_queue_t queue1 = dispatch_queue_create("test.1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("test.2", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue3 = dispatch_queue_create("test.3", DISPATCH_QUEUE_SERIAL);
    
    dispatch_set_target_queue(queue1, targetQueue);
    dispatch_set_target_queue(queue2, targetQueue);
    dispatch_set_target_queue(queue3, targetQueue);
    
    dispatch_async(queue1, ^{
        NSLog(@"1 in");
        [NSThread sleepForTimeInterval:3.f];
        NSLog(@"1 out");
    });
    dispatch_async(queue2, ^{
        NSLog(@"2 in");
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"2 out");
    });
    dispatch_async(queue3, ^{
        NSLog(@"3 in");
        [NSThread sleepForTimeInterval:1.f];
        NSLog(@"3 out");
    });
}

/**
 实现改变队列优先级
 */
- (void)testTargetQueuePriority
{
    //优先级变更的串行队列，初始是默认优先级
    dispatch_queue_t serialQueue = dispatch_queue_create("com.gcd.setTargetQueue.serialQueue", NULL);
    
    //优先级不变的串行队列（参照），初始是默认优先级
    dispatch_queue_t serialDefaultQueue = dispatch_queue_create("com.gcd.setTargetQueue.serialDefaultQueue", NULL);
    
    //变更前
    dispatch_async(serialQueue, ^{
        NSLog(@"1");
    });
    dispatch_async(serialDefaultQueue, ^{
        NSLog(@"2");
    });
    
    //获取优先级为后台优先级的全局队列
    dispatch_queue_t globalDefaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    //变更优先级
    dispatch_set_target_queue(serialQueue, globalDefaultQueue);
    
    //变更后
    dispatch_async(serialQueue, ^{
        NSLog(@"1");
    });
    dispatch_async(serialDefaultQueue, ^{
        NSLog(@"2");
    });
}

#pragma mark    -   GCD预加载UI资源

- (dispatch_queue_t)serialQueue
{
    if (!_serialQueue) {
        _serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);//创建串行队列
    }
    return _serialQueue;
}

- (void)prepareViewControllerAndJumpTo
{
    dispatch_async([self serialQueue], ^{//把block中的任务放入串行队列中执行，这是第一个任务
        self.viewController = [[TestPreLoadViewController alloc] init];
        sleep(2);//假装这个viewController创建起来很花时间。。其实view都还没加载，根本不花时间。
        NSLog(@"prepared");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self goToViewController];
        });
    });
}

- (void)goToViewController
{
    dispatch_async([self serialQueue], ^{//第二个任务，推入viewController
        NSLog(@"go");
        dispatch_async(dispatch_get_main_queue(), ^{//涉及UI更新的操作，放入主线程中
            [self.navigationController pushViewController:self.viewController animated:YES];
        });
    });
}

#pragma mark    -   GCD如何取消任务执行,2中

/**
 自定义外部标识,必要的地方判断标识状态,进行手动退出block实现取消正在执行的任务 ,
 真正要去使用的时候,要考虑资源竞争,按情况使用锁机制
 */
- (void)gcdCancelCustom{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block BOOL isCancel = NO;
    dispatch_async(queue, ^{
        NSLog(@"任务001 %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务002 %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务003 %@",[NSThread currentThread]);
        isCancel = YES;
    });
    
    dispatch_async(queue, ^{
        // 模拟：线程等待3秒，确保任务003完成 isCancel＝YES
        sleep(3);
        if(isCancel){
            // 回收资源, dosomething
            NSLog(@"任务004已被取消 %@",[NSThread currentThread]);
        }else{
            NSLog(@"任务004 %@",[NSThread currentThread]);
        }
    });
}

/**
 使用dispatch_block_cancel 来
 */
- (void)gcdBlockCancel{
    
    dispatch_queue_t queue = dispatch_queue_create("com.CoderXL.Test------", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t block1 = dispatch_block_create(0, ^{
        sleep(4);
        NSLog(@"block1 %@",[NSThread currentThread]);
    });
    dispatch_block_t block2 = dispatch_block_create(0, ^{
        NSLog(@"block2 %@",[NSThread currentThread]);
    });
    
    dispatch_block_t block3 = dispatch_block_create(0, ^{
        NSLog(@"block3 %@",[NSThread currentThread]);
    });
    // 添加block进队列
    dispatch_async(queue, block1);
    dispatch_async(queue, block2);
    dispatch_async(queue, block3);
    
    // block1有4秒延迟, 在执行到block3之前,调用dispatch_block_cancel取消block3
    dispatch_block_cancel(block3);
}

#pragma mark    -   GCD中sync和async的区别

/**
 测试Sync 和 Async类函数
 1. 开启线程能力不同,sync不会开启新线程 , 一条都不会开启, 只会在当前线程操作
 2. 添加任务方式不同,尤其是和dispatch_barrier_async和dispatch_barrier_sync的区别上更明显
 */
- (void)testSyncAndAsync
{
    dispatch_queue_t queue = dispatch_queue_create("thread", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        sleep(3);
        NSLog(@"test1 , %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"test2 , %@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"test3 , %@",[NSThread currentThread]);
    });
    dispatch_barrier_sync(queue, ^{///分界线在这里 请注意是同步的
        sleep(2);
        for (int i = 0; i<50; i++) {
            if (i == 10 ) {
                NSLog(@"point1, %@",[NSThread currentThread]);
            }else if(i == 20){
                NSLog(@"point2, %@",[NSThread currentThread]);
            }else if(i == 40){
                NSLog(@"point3, %@",[NSThread currentThread]);
            }
        }
    });
    
    NSLog(@"hello, %@",[NSThread currentThread]);
    
    dispatch_async(queue, ^{
        NSLog(@"test4, %@",[NSThread currentThread]);
    });
    
    NSLog(@"world, %@",[NSThread currentThread]);
    
    dispatch_async(queue, ^{
        NSLog(@"test5, %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"test6, %@",[NSThread currentThread]);
    });
    /*
     2018-03-24 20:22:03.289217+0800 Test - 多线程[13714:18161035] test3 , <NSThread: 0x604000262500>{number = 1, name = main}
     2018-03-24 20:22:03.289226+0800 Test - 多线程[13714:18161162] test2 , <NSThread: 0x6000004678c0>{number = 3, name = (null)}
     2018-03-24 20:22:06.290664+0800 Test - 多线程[13714:18161160] test1 , <NSThread: 0x604000474280>{number = 4, name = (null)}
     2018-03-24 20:22:08.292302+0800 Test - 多线程[13714:18161035] point1, <NSThread: 0x604000262500>{number = 1, name = main}
     2018-03-24 20:22:08.292604+0800 Test - 多线程[13714:18161035] point2, <NSThread: 0x604000262500>{number = 1, name = main}
     2018-03-24 20:22:08.292795+0800 Test - 多线程[13714:18161035] point3, <NSThread: 0x604000262500>{number = 1, name = main}
     2018-03-24 20:22:08.292967+0800 Test - 多线程[13714:18161035] hello, <NSThread: 0x604000262500>{number = 1, name = main}
     2018-03-24 20:22:08.293157+0800 Test - 多线程[13714:18161035] world, <NSThread: 0x604000262500>{number = 1, name = main}
     2018-03-24 20:22:08.293189+0800 Test - 多线程[13714:18161160] test4, <NSThread: 0x604000474280>{number = 4, name = (null)}
     2018-03-24 20:22:08.293484+0800 Test - 多线程[13714:18161162] test5, <NSThread: 0x6000004678c0>{number = 3, name = (null)}
     2018-03-24 20:22:08.293531+0800 Test - 多线程[13714:18161160] test6, <NSThread: 0x604000474280>{number = 4, name = (null)}
     
     */
}

/**
 测试Sync 和 Async类函数
 */
- (void)testdispatch_barrier_async
{
    NSLog(@"testdispatch_barrier_async");
    dispatch_queue_t queue = dispatch_queue_create("thread", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        sleep(3);
        NSLog(@"test1 , %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"test2 , %@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"test3 , %@",[NSThread currentThread]);
    });
    dispatch_barrier_async(queue, ^{///分界线在这里 请注意是异步的
        sleep(2);
        for (int i = 0; i<50; i++) {
            if (i == 10 ) {
                NSLog(@"point1, %@",[NSThread currentThread]);
            }else if(i == 20){
                NSLog(@"point2, %@",[NSThread currentThread]);
            }else if(i == 40){
                NSLog(@"point3, %@",[NSThread currentThread]);
            }
        }
    });
    
    NSLog(@"hello, %@",[NSThread currentThread]);
    
    dispatch_async(queue, ^{
        NSLog(@"test4, %@",[NSThread currentThread]);
    });
    
    NSLog(@"world, %@",[NSThread currentThread]);
    
    dispatch_async(queue, ^{
        NSLog(@"test5, %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"test6, %@",[NSThread currentThread]);
    });
    /*
     2018-03-24 20:25:05.358017+0800 Test - 多线程[13779:18169261] testdispatch_barrier_async
     2018-03-24 20:25:05.358331+0800 Test - 多线程[13779:18169261] test3 , <NSThread: 0x600000067500>{number = 1, name = main}
     2018-03-24 20:25:05.358394+0800 Test - 多线程[13779:18169785] test2 , <NSThread: 0x60400027af00>{number = 3, name = (null)}
     2018-03-24 20:25:05.358544+0800 Test - 多线程[13779:18169261] hello, <NSThread: 0x600000067500>{number = 1, name = main}
     2018-03-24 20:25:05.358659+0800 Test - 多线程[13779:18169261] world, <NSThread: 0x600000067500>{number = 1, name = main}
     2018-03-24 20:25:08.362785+0800 Test - 多线程[13779:18169392] test1 , <NSThread: 0x60400027c940>{number = 4, name = (null)}
     2018-03-24 20:25:10.368349+0800 Test - 多线程[13779:18169392] point1, <NSThread: 0x60400027c940>{number = 4, name = (null)}
     2018-03-24 20:25:10.368699+0800 Test - 多线程[13779:18169392] point2, <NSThread: 0x60400027c940>{number = 4, name = (null)}
     2018-03-24 20:25:10.368983+0800 Test - 多线程[13779:18169392] point3, <NSThread: 0x60400027c940>{number = 4, name = (null)}
     2018-03-24 20:25:10.369274+0800 Test - 多线程[13779:18169392] test4, <NSThread: 0x60400027c940>{number = 4, name = (null)}
     2018-03-24 20:25:10.369317+0800 Test - 多线程[13779:18169938] test5, <NSThread: 0x604000461100>{number = 5, name = (null)}
     2018-03-24 20:25:10.369326+0800 Test - 多线程[13779:18169785] test6, <NSThread: 0x60400027af00>{number = 3, name = (null)}
     */
}

@end
