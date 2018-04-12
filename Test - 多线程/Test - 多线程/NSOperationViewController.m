//
//  NSOperationViewController.m
//  Test - 多线程
//
//  Created by XL on 2017/7/3.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "NSOperationViewController.h"
#import "XLOperation.h"
#import "XLOperationQueue.h"
#import "XLAsyncOperation.h"

@interface NSOperationViewController ()

@property (nonatomic , strong)UIImageView  *imageView;
@property (nonatomic, strong) XLOperationQueue *queue;

@end

@implementation NSOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addTestButtonWithTitle:@"blockOperation" selector:@selector(blockOperation)];
    [self addTestButtonWithTitle:@"invocationOperation" selector:@selector(invocationOperation)];
    [self addTestButtonWithTitle:@"startOperationQueue" selector:@selector(startOperationQueue)];
    [self addTestButtonWithTitle:@"cancelOperationQueue" selector:@selector(cancelOperationQueue)];
    [self addTestButtonWithTitle:@"suspendedOperationQueue" selector:@selector(suspendedOperationQueue)];
    [self addTestButtonWithTitle:@"operationQueueBase" selector:@selector(operationQueueBase)];
    [self addTestButtonWithTitle:@"opetationQueueLikeSerial" selector:@selector(opetationQueueLikeSerial)];

    [self addTestButtonWithTitle:@"customOperation" selector:@selector(customOperation)];
    [self addTestButtonWithTitle:@"testBlockOperationSuspend" selector:@selector(testBlockOperationSuspend)];
    [self addTestButtonWithTitle:@"testCancel" selector:@selector(testCancel)];
    [self addTestButtonWithTitle:@"customAsyncOperation" selector:@selector(customAsyncOperation)];
    [self addTestButtonWithTitle:@"testDependency" selector:@selector(testDependency)];
    

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 100, 100)];
    self.imageView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.imageView];
}

#pragma mark    -   testCancel


/**
 2017-07-04 15:16:40.477 Test - 多线程[16998:4334556] testCancel begin ,thread = <NSThread: 0x600000268fc0>{number = 3, name = (null)}
 2017-07-04 15:16:41.478 Test - 多线程[16998:4331226] op1---i = 0,thread = <NSThread: 0x608000263200>{number = 4, name = (null)},queue.suspended=0
 2017-07-04 15:16:42.478 Test - 多线程[16998:4330777] will cancelAllOperations in queue=<XLOperationQueue: 0x60800022b5c0>{name = 'NSOperationQueue 0x60800022b5c0'}
 2017-07-04 15:16:42.552 Test - 多线程[16998:4331226] op1---i = 1,thread = <NSThread: 0x608000263200>{number = 4, name = (null)},queue.suspended=0
 2017-07-04 15:16:43.627 Test - 多线程[16998:4331226] op1---i = 2,thread = <NSThread: 0x608000263200>{number = 4, name = (null)},queue.suspended=0
 2017-07-04 15:16:43.628 Test - 多线程[16998:4334556] testCancel end ,thread = <NSThread: 0x600000268fc0>{number = 3, name = (null)}
 2017-07-04 15:16:43.628 Test - 多线程[16998:4334556] XLOperationQueue = <XLOperationQueue: 0x60800022b5c0>{name = 'NSOperationQueue 0x60800022b5c0'} , dealloc
 结论:
 在执行op1期间调用cancel,正在执行的op1会继续执行,后面的op2,op3任务不执行
 testCancel end在后面打印是因为waitUntilFinished:YES,同步等待队列中任务执行完毕
 */
- (void)testCancel
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"testCancel begin ,thread = %@",[NSThread currentThread]);
        XLOperationQueue *queue = [[XLOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
            for (int i = 0 ; i < 3; i++) {
                [NSThread sleepForTimeInterval:1];
                NSLog(@"op1---i = %zd,thread = %@,queue.suspended=%zd",i,[NSThread currentThread],queue.suspended);
            }
        }];
        NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
            for (int i = 0 ; i < 3; i++) {
                [NSThread sleepForTimeInterval:1];
                NSLog(@"op2---i = %zd,thread = %@,queue.suspended=%zd",i,[NSThread currentThread],queue.suspended);
            }
        }];
        NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
            [NSThread sleepForTimeInterval:1];
            NSLog(@"op3 ,thread = %@,queue.suspended=%zd",[NSThread currentThread],queue.suspended);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"will cancelAllOperations in queue=%@",queue);
            [queue cancelAllOperations];
        });
        [op2 addDependency:op3]; // 依赖关系放到添加进queue之前,因为添加进队列就会自动开始执行,
        [op3 addDependency:op1];
        
        [queue addOperation:op3];
        [queue addOperations:@[op1,op2] waitUntilFinished:NO];
        NSLog(@"testCancel end ,thread = %@",[NSThread currentThread]);
    });
}


#pragma mark    -   test suspend


/**
 2017-07-04 15:18:05.005 Test - 多线程[16998:4335832] testSuspend begin ,thread = <NSThread: 0x600000268fc0>{number = 5, name = (null)}
 2017-07-04 15:18:05.005 Test - 多线程[16998:4335832] testSuspend end ,thread = <NSThread: 0x600000268fc0>{number = 5, name = (null)}
 2017-07-04 15:18:06.006 Test - 多线程[16998:4331226] op1---i = 0,thread = <NSThread: 0x608000263200>{number = 4, name = (null)},queue.suspended=0
 2017-07-04 15:18:07.005 Test - 多线程[16998:4330777] will suspend queue
 2017-07-04 15:18:07.082 Test - 多线程[16998:4331226] op1---i = 1,thread = <NSThread: 0x608000263200>{number = 4, name = (null)},queue.suspended=1
 2017-07-04 15:18:08.158 Test - 多线程[16998:4331226] op1---i = 2,thread = <NSThread: 0x608000263200>{number = 4, name = (null)},queue.suspended=1
 2017-07-04 15:18:17.006 Test - 多线程[16998:4330777] will resume queue
 2017-07-04 15:18:18.078 Test - 多线程[16998:4335832] op3 ,thread = <NSThread: 0x600000268fc0>{number = 5, name = (null)},queue.suspended=0
 2017-07-04 15:18:19.079 Test - 多线程[16998:4336101] op2---i = 0,thread = <NSThread: 0x608000263200>{number = 6, name = (null)},queue.suspended=0
 2017-07-04 15:18:20.154 Test - 多线程[16998:4336101] op2---i = 1,thread = <NSThread: 0x608000263200>{number = 6, name = (null)},queue.suspended=0
 2017-07-04 15:18:21.229 Test - 多线程[16998:4336101] op2---i = 2,thread = <NSThread: 0x608000263200>{number = 6, name = (null)},queue.suspended=0
 2017-07-04 15:18:21.230 Test - 多线程[16998:4336101] XLOperationQueue = <XLOperationQueue: 0x600000033120>{name = 'NSOperationQueue 0x600000033120'} , dealloc
 在op1期间调用suspended = YES,正在执行的op1会继续执行,但是后面的任务会被暂停,直到suspended = NO后恢复队列,继续执行任务
 */
- (void)testBlockOperationSuspend
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"testSuspend begin ,thread = %@",[NSThread currentThread]);
        XLOperationQueue *queue = [[XLOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
            for (int i = 0 ; i < 3; i++) {
                [NSThread sleepForTimeInterval:1];
                NSLog(@"op1---i = %zd,thread = %@,queue.suspended=%zd",i,[NSThread currentThread],queue.suspended);
            }
        }];
        NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
            for (int i = 0 ; i < 3; i++) {
                [NSThread sleepForTimeInterval:1];
                NSLog(@"op2---i = %zd,thread = %@,queue.suspended=%zd",i,[NSThread currentThread],queue.suspended);
            }
        }];
        NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
            [NSThread sleepForTimeInterval:1];
            NSLog(@"op3 ,thread = %@,queue.suspended=%zd",[NSThread currentThread],queue.suspended);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"will suspend queue");
            queue.suspended = YES; // 暂停queue中将要执行的任务,当前执行的任务并不会停止
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"will resume queue");
                queue.suspended = NO;// 恢复queue的任务继续执行
            });
        });
        [op2 addDependency:op3]; // 依赖关系放到添加进queue之前,因为添加进队列就会自动开始执行,
        [op3 addDependency:op1];
        
        [queue addOperation:op3];
        [queue addOperations:@[op1,op2] waitUntilFinished:NO]; // waitUntilFinished=yes,阻塞当前线程直到上面的任务都执行完毕,才会往下执行
        NSLog(@"testSuspend end ,thread = %@",[NSThread currentThread]);
    });
}
#pragma mark    -   custom async operation
- (void)customAsyncOperation
{
    XLAsyncOperation *op = [[XLAsyncOperation alloc] init];
    [op start];
}

#pragma mark    -   custom operation

- (void)customOperation
{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//    });
    NSLog(@"customOperation begin , thread = %@",[NSThread currentThread]);
    XLOperation *op = [[XLOperation alloc] init];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"自定义XLOperation 调用cancel方法 , 查看是否中断XLOperation任务执行");
        [op cancel];
    });
    [op start];
    NSLog(@"customOperation end , thread = %@",[NSThread currentThread]);
    
}

#pragma mark    -   operation base use


/**
 一个blockOperation中添加多个任务时, 不加入队列也会开启多个线程,单个任务不会开启新线程
 */
- (void)blockOperation
{
//    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
//        // 在主线程
//        for (int i = 0 ; i < 10; i ++) {
//            NSLog(@"下载1------%@", [NSThread currentThread]);
//        }
//    }];
//    
//    // 添加额外的任务(在子线程执行)
//    [op addExecutionBlock:^{
//        for (int i = 0 ; i < 10; i ++) {
//            NSLog(@"下载2------%@", [NSThread currentThread]);
//        }
//    }];
//    [op addExecutionBlock:^{
//        for (int i = 0 ; i < 10; i ++) {
//            NSLog(@"下载3------%@", [NSThread currentThread]);
//        }
//    }];
//    [op addExecutionBlock:^{
//        for (int i = 0 ; i < 10; i ++) {
//            NSLog(@"下载4------%@", [NSThread currentThread]);
//        }
//    }];
//    
//    [op start];
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{ // 在主线程
        NSLog(@"下载1------%@", [NSThread currentThread]);
    }];
    [op addExecutionBlock:^{ // 添加额外的任务(在子线程执行)
        NSLog(@"下载2------%@", [NSThread currentThread]);
    }];
    [op start];//开始执行任务
}

- (void)invocationOperation
{
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(run) object:nil];
    [op start];
    
    // 并不能执行runMethodSignature,不知为何
//    NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:@selector(runMethodSignature)];
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
//    NSInvocationOperation *invocationOp = [[NSInvocationOperation alloc] initWithInvocation:invocation];
//    [invocationOp start];
}

- (void)run
{
    for (int i = 0 ; i < 10; i ++) {
        NSLog(@"run------%@", [NSThread currentThread]);//2017-07-03 19:19:52.290 Test - 多线程[2428:3743732] run------<NSThread: 0x60800007f240>{number = 1, name = main}

    }
}

- (void)runMethodSignature
{
    for (int i = 0 ; i < 10; i ++) {
        NSLog(@"runMethodSignature------%@", [NSThread currentThread]);
    }
}

#pragma mark    -   operation queue

- (void)startOperationQueue {
    // 创建队列
    XLOperationQueue *queue = [[XLOperationQueue alloc] init];
    [queue addOperation:[[XLOperation alloc] init]];
    self.queue = queue;
}

/**
 取消队列中的所有任务 , 并不能真的取消任务执行,只是把队列中所有operation的cancel状态置为YES,如果要取消任务,还应该在operation里面多出监听cancel状态,检测到cancel=yes,就return中断任务,例如XLOperation中main方法
 */
- (void)cancelOperationQueue{
    NSLog(@"cancelOperationQueue = %@",self.queue);
    [self.queue cancelAllOperations];
}

/**
 暂停队列中的所有任务,当前正在执行的block不能停止,只能停止后面没开始执行的任务 ,
 可以自定义operation.内部添加监听点,实现暂停正在执行的operation功能
 */
- (void)suspendedOperationQueue
{
    if (self.queue.isSuspended) {
        // 恢复队列，继续执行
        self.queue.suspended = NO;
    } else {
        // 暂停（挂起）队列，暂停执行
        self.queue.suspended = YES;
    }
    NSLog(@"change self.queue suspend = %zd",self.queue.suspended);
}

/**
 类似串行队列
 */
- (void)opetationQueueLikeSerial
{
    // 创建队列
    XLOperationQueue *queue = [[XLOperationQueue alloc] init];
    
    // 设置最大并发操作数
    //    queue.maxConcurrentOperationCount = 2;
    queue.maxConcurrentOperationCount = 1; // 就变成了串行队列
    
    // 添加操作
    [queue addOperationWithBlock:^{
        NSLog(@"download1 --- %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"download2 --- %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"download3 --- %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"download4 --- %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"download5 --- %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"download6 --- %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:0.01];
    }];
}

- (void)operationQueueBase
{
    NSLog(@"operationQueueBase begin %@",[NSThread currentThread]);
    // 创建队列
    XLOperationQueue *queue = [[XLOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 2;//设置最大并发数为2
    // 创建操作（任务）
    // 创建NSInvocationOperation
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(download1) object:nil];
    
    // 创建XLOperation
    XLOperation *op2 = [[XLOperation alloc] init];
    [op2 setCompletionBlock:^{
        NSLog(@"op2 finished %@",[NSThread currentThread]);
    }];
    
    // 创建NSBlockOperation
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"download3 111 --- %@", [NSThread currentThread]);
    }];
    [op3 addExecutionBlock:^{
        NSLog(@"download3 222 --- %@", [NSThread currentThread]);
    }];
    
    // 设置任务依赖
    [op2 addDependency:op3];// op3执行完毕以后,再执行op2
    
    // 添加任务到队列中
    [queue addOperation:op1]; // [op1 start]
    [queue addOperations:@[op2,op3] waitUntilFinished:YES];
    NSLog(@"operationQueueBase end %@",[NSThread currentThread]);
}

- (void)download1
{
    NSLog(@"download1 --- %@", [NSThread currentThread]);
}

#pragma mark - testDependency
/**
 设置任务的依赖关系,实现线程同步
 */
- (void)testDependency
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"testDependency begin ,thread = %@",[NSThread currentThread]);
        XLOperationQueue *queue = [[XLOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
            for (int i = 0 ; i < 3; i++) {
                [NSThread sleepForTimeInterval:1];
                NSLog(@"op1---i = %zd,thread = %@,queue.suspended=%zd",i,[NSThread currentThread],queue.suspended);
            }
        }];
        NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
            for (int i = 0 ; i < 3; i++) {
                [NSThread sleepForTimeInterval:1];
                NSLog(@"op2---i = %zd,thread = %@,queue.suspended=%zd",i,[NSThread currentThread],queue.suspended);
            }
        }];
        NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
            [NSThread sleepForTimeInterval:1];
            NSLog(@"op3 ,thread = %@,queue.suspended=%zd",[NSThread currentThread],queue.suspended);
        }];
        [op2 addDependency:op3]; // 依赖关系放到添加进queue之前,因为添加进队列就会自动开始执行,
        [op3 addDependency:op1];
        
        [queue addOperation:op3];
        [queue addOperations:@[op1,op2] waitUntilFinished:NO]; // 不会阻塞当前线程,"testCancel end ,thread =XXX"很快就会输出,基本在op1/3/2执行之前就已经输出
        //        [queue addOperations:@[op1,op2] waitUntilFinished:YES]; // waitUntilFinished=yes,阻塞当前线程直到上面的任务都执行完毕,才会往下执行 "testCancel end ,thread =XXX"会在queue中所有operation执行完毕后输出
        NSLog(@"testDependency end ,thread = %@",[NSThread currentThread]);
    });
}

@end
