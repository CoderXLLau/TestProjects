//
//  PthreadViewController.m
//  Test - 多线程
//
//  Created by XL on 2017/6/27.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "PthreadViewController.h"
#import <pthread.h>
#import <sys/_pthread/_pthread_types.h>

@interface PthreadViewController ()

@end

@implementation PthreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addTestButtonWithTitle:@"TestCancelThread" selector:@selector(TestCancelThread)];
    [self addTestButtonWithTitle:@"testCreatJoinDetach" selector:@selector(testCreatJoinDetach)];
    [self addTestButtonWithTitle:@"TestKillThread" selector:@selector(TestKillThread)];
}

#pragma mark    -   测试Creat Join Detach等方法

- (void)testCreatJoinDetach
{
    pthread_t thread1;
    pthread_attr_t att;
    pthread_attr_init(&att);
    int result = pthread_create(&thread1, &att, run1, nil);//创建一个线程
    if (result == 0) {
        NSLog(@"创建线程 OK");
    } else {
        NSLog(@"创建线程失败 %d", result);
    }
    NSLog(@"111(*thread1).__sig = %ld ,(*thread1).__opaque = %s, thread1 = %p",(*thread1).__sig ,(*thread1).__opaque , thread1);
    
    NSLog(@"before pthread_join ");
    void * thread1Return;
    pthread_join(thread1, &thread1Return);//当前线程被阻塞,等待线程1结束后恢复
    NSLog(@"after pthread_join ; thread1Return = %zd ",(!thread1Return) ? 0 : (int)(*((int *)thread1Return)));

    pthread_t thread2;
    int a = 2;
    pthread_create(&thread2, NULL, (void *)run2, &a);
    pthread_detach(thread2); // 或者在run2中调用pthread_detach(pthread_self());
}

int a = 88;
void * run1 (void *prama)
{
    if (!prama) {
        NSLog(@"run1 prama = null");
    } else {
        NSLog(@"run1 prama = %d\n", (int)(*((int*)prama)));
    }
    for (int i = 0; i<5000; i++) {
        NSLog(@"---run1--%d---%@",i,[NSThread currentThread]);
    }
    return &a;
}

void run2 (void *prama)
{
    if (!prama) {
        NSLog(@"run2 prama = null");
    } else {
        NSLog(@"run2 prama = %d\n", (int)(*((int*)prama)));
    }
    for (int i = 0; i<5000; i++) {
        NSLog(@"--run2---%d---%@",i,[NSThread currentThread]);
    }
//    pthread_detach(pthread_self());
}

#pragma mark    -    测试 cancel

- (void)TestCancelThread
{
    //创建一个线程对象
    pthread_t thread1;
    int result = pthread_create(&thread1, NULL, cancelRun, nil);
    if (result == 0) {
        NSLog(@"创建线程 OK");
    } else {
        NSLog(@"创建线程失败 %d", result);
    }
//    NSLog(@"111(*thread1).__sig = %ld ,(*thread1).__opaque = %s, thread1 = %p",(*thread1).__sig ,(*thread1).__opaque , thread1);
//    
//    sleep(0.5);
//    
//    NSLog(@"222(*thread1).__sig = %ld ,(*thread1).__opaque = %s, thread1 = %p",(*thread1).__sig ,(*thread1).__opaque , thread1);
    if (pthread_cancel(thread1) == 0) { // 取消线程
        NSLog(@"thread1 取消信号发送成功");
    } else {
        NSLog(@"thread1 取消信号发送失败");
    };

    void *value ;
    if (pthread_join(thread1, &value) == 0) { // pthread_join触发取消点,并回收资源
        NSLog(@"thread1 已终止,资源被回收 , 返回值 = %p",value);
    } else {
        NSLog(@"thread1 未终止, 返回值 = %zd",(int)(*((int *)value)));
    };
    
    [self testThreadLife:thread1];
}

void * cancelRun (void *prama)
{
    pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, NULL); // 忽略取消信号,即使收到其他线程调用pthread_cancel,也会继续执行任务
    pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);// 设置收到取消信号,立即取消
    if (!prama) {
        printf("run1 prama = null\n");
    } else {
        printf("run1 prama = %d\n", (int)(*((int*)prama)));
    }
    for (int i = 0; i<5000; i++) {
//        pthread_testcancel();
//        NSLog(@"---run1--%d---%@\n",i,[NSThread currentThread]);
//        NSLog(@"---run1--%d---\n",i);
        printf("---run1--%d---\n",i);

    }
    return NULL;
}

void * cancelRun2 (void *prama)
{
    pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
    pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);// 设置收到取消信号,立即取消
    int i = 1;
    while (i > 0) {
        i ++;
        printf("---cancelRun2 running----i = %d-\n",i);
    }
    return NULL;
}

#pragma mark    -   touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

}
#pragma mark    -   测试线程是否终止

- (void)testThreadLife:(pthread_t)thread
{
    int kill_ret = pthread_kill(thread,0);// 其他宏信号量:SIGUSR1等

    if(kill_ret == ESRCH)
        NSLog(@"指定的线程不存在或者是已经终止\n");
    else if(kill_ret == EINVAL)
        NSLog(@"调用传递一个无用的信号\n");
    else
        NSLog(@"线程存在\n");
//    pthread_yield_np();
}

#pragma mark    -   测试 互斥量

//void reader_function (void);
//void writer_function (void);
//char buffer;
//int buffer_has_item=0;
//pthread_mutex_t mutex;
//struct timespec delay;
//void main (void)
//{
//    pthread_t reader;
//    /* 定义延迟时间*/
//    delay.tv_sec =2;
//    delay.tv_nsec =0;
//    
//    /* 用默认属性初始化一个互斥锁对象*/
//    pthread_mutex_init (&mutex,NULL);
//    pthread_create(&reader, NULL,(void*)&reader_function, NULL);
//    writer_function();
//}
//
//void writer_function (void){
//    while(1){
////        pthread_delay_np();
//        /* 锁定互斥锁*/
//        pthread_mutex_lock (&mutex);
//        if(buffer_has_item==0){
//            buffer= make_new_item();
//            buffer_has_item=1;
//        }
//        /* 打开互斥锁*/
//        pthread_mutex_unlock(&mutex);
//        pthread_delay_np(&delay);
//    }
//}
//void reader_function(void){
//    while(1){
//        pthread_mutex_lock(&mutex);
//        if(buffer_has_item==1){
//
//            buffer_has_item=0;
//        }
//        pthread_mutex_unlock(&mutex);
//        pthread_delay_np(&delay);
//    }
//}


#pragma mark    -   测试pthread_kill,向线程发送一个信号 ,  发送自定义信号量

//
//#include<stdio.h>
//#include<unistd.h>
//#include<signal.h>
//#include<pthread.h>
//#include<time.h>
//pthread_t tid;
//sigset_t set;
//void myfunc()
//{
//    printf("hello\n");
//}
//
//static void *mythread(void*p)
//{
//    int signum;
//    while(1){
//        sigwait(&set,&signum);
//        if(SIGUSR1==signum)
//            myfunc();
//        if(SIGUSR2==signum)
//        {
//            printf("Iwillsleep2secondandexit\n");
//            sleep(2);
//            break;
//        }
//    }
//    return NULL;
//}
//
//int main()
//{
//    char tmp;
//    void *status;
//    sigemptyset(&set);
//    sigaddset(&set,SIGUSR1);
//    sigaddset(&set,SIGUSR2);
//    sigprocmask(SIG_SETMASK,&set,NULL);
//    pthread_create(&tid,NULL,mythread,NULL);
//    while(1)
//    {
//        printf(":");
//        scanf("%c",&tmp);
//        if('a'==tmp)
//        {
//            pthread_kill(tid,SIGUSR1);//发送SIGUSR1，打印字符串。
//        }
//        else if('q'==tmp)
//        {
//            //发出SIGUSR2信号，让线程退出，如果发送SIGKILL，线程将直接退出。
//            pthread_kill(tid,SIGUSR2);
//            //等待线程tid执行完毕，这里阻塞。
//            pthread_join(tid,&status);
//            printf("finish\n");
//            break;
//        }
//        else
//            continue;
//    }
//    return 0;
//}



@end
