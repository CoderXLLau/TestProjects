//
//  XLGCDTimer.m
//  Test - 多线程
//
//  Created by shannoon on 2017/6/29.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import "XLGCDTimer.h"

@interface XLGCDTimer ()

@property (nonatomic, strong) NSMutableDictionary *timerContainer;
@property(nonatomic, strong) NSMutableDictionary *timerRepeatCou;
@property (nonatomic, strong) NSMutableDictionary *actionBlockCache;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation XLGCDTimer

#pragma mark - Public Method

+ (XLGCDTimer *)sharedGCDTimer
{
    static XLGCDTimer *_gcdTimerManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        _gcdTimerManager = [[XLGCDTimer alloc] init];
    });
    
    return _gcdTimerManager;
}

/**
 启动一个可指定循环次数的timer，默认精度为0.1秒。
 
 @param timerName       timer的名称，作为唯一标识。
 @param interval        执行的时间间隔。
 @param queue           timer将被放入的队列，也就是最终action执行的队列。传入nil将自动放到一个子线程队列中。
 @param repeatsCount         timer循环调用次数。
 @param option    多次schedule同一个timer时的操作选项(目前提供将之前的任务废除或合并的选项)。
 @param action          时间间隔到点时执行的block。
 @param endAction       循环调用结束时执行的block。
 */
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(double)interval
                                 queue:(dispatch_queue_t)queue
                          repeatsCount:(NSInteger)repeatsCount
                          actionOption:(XLActionOption)option
                                action:(dispatch_block_t)action
                             endAction:(dispatch_block_t)endAction
{
    if (nil == timerName)
        return;
    
    if (repeatsCount <=0) {
        return;
    }
    // 其他线程中这个integer会不会释放掉?可能这里有问题
    __block NSInteger repeatsCountInBlock = repeatsCount;
    dispatch_block_t cycleAction = ^(){
        repeatsCountInBlock --;
        if (action) {
            action();
        }
    };
    
    if (nil == queue)
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t timer = [self.timerContainer objectForKey:timerName];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_resume(timer);
        [self.timerContainer setObject:timer forKey:timerName];
    }
    
    /* timer精度为0.1秒 */
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    
    switch (option) {
            
        case XLActionOptionAbandonPreviousAction:
        {
            /* 移除之前的action */
            [weakSelf removeActionCacheForTimer:timerName];
            
            dispatch_source_set_event_handler(timer, ^{
                cycleAction();
                
                if (repeatsCount <= 0) {
                    [weakSelf cancelTimerWithName:timerName];
                }
            });
        }
            break;
            
        case XLActionOptionMergePreviousAction:
        {
            /* cache本次的action */
            [self cacheAction:cycleAction forTimer:timerName];
            
            dispatch_source_set_event_handler(timer, ^{
                NSMutableArray *actionArray = [self.actionBlockCache objectForKey:timerName];
                [actionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    dispatch_block_t actionBlock = obj;
                    actionBlock();
                }];
                [weakSelf removeActionCacheForTimer:timerName];
                
                if (repeatsCount <= 0) {
                    [weakSelf cancelTimerWithName:timerName];
                }
            });
        }
            break;
    }
}

/**
 创建可以一直循环执行的定时器
 */
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(double)interval
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                          actionOption:(XLActionOption)option
                                action:(dispatch_block_t)action
{
    if (nil == timerName)
        return;
    
    if (nil == queue)
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t timer = [self.timerContainer objectForKey:timerName];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_resume(timer);
        [self.timerContainer setObject:timer forKey:timerName];
    }
    
    /* timer精度为0.1秒 */
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    
    switch (option) {
            
        case XLActionOptionAbandonPreviousAction:
        {
            /* 移除之前的action */
            [weakSelf removeActionCacheForTimer:timerName];
            
            dispatch_source_set_event_handler(timer, ^{
                action();
                
                if (!repeats) {
                    [weakSelf cancelTimerWithName:timerName];
                }
            });
        }
            break;
            
        case XLActionOptionMergePreviousAction:
        {
            /* cache本次的action */
            [self cacheAction:action forTimer:timerName];
            
            dispatch_source_set_event_handler(timer, ^{
                NSMutableArray *actionArray = [self.actionBlockCache objectForKey:timerName];
                [actionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    dispatch_block_t actionBlock = obj;
                    actionBlock();
                }];
                [weakSelf removeActionCacheForTimer:timerName];
                
                if (!repeats) {
                    [weakSelf cancelTimerWithName:timerName];
                }
            });
        }
            break;
    }
}

- (void)cancelTimerWithName:(NSString *)timerName
{
    dispatch_source_t timer = [self.timerContainer objectForKey:timerName];

    if (!timer) {
        return;
    }
    
    [self.timerContainer removeObjectForKey:timerName];
    dispatch_source_cancel(timer);
    
    [self.actionBlockCache removeObjectForKey:timerName];
}

- (BOOL)existTimer:(NSString *)timerName
{
    if ([self.timerContainer objectForKey:timerName]) {
        return YES;
    }
    return NO;
}

#pragma mark - Property

- (NSMutableDictionary *)timerContainer
{
    if (!_timerContainer) {
        _timerContainer = [[NSMutableDictionary alloc] init];
    }
    return _timerContainer;
}

- (NSMutableDictionary *)actionBlockCache
{
    if (!_actionBlockCache) {
        _actionBlockCache = [[NSMutableDictionary alloc] init];
    }
    return _actionBlockCache;
}

#pragma mark - Action Cache

- (void)cacheAction:(dispatch_block_t)action forTimer:(NSString *)timerName
{
    id actionArray = [self.actionBlockCache objectForKey:timerName];
    
    if (actionArray && [actionArray isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray *)actionArray addObject:action];
    }else {
        NSMutableArray *array = [NSMutableArray arrayWithObject:action];
        [self.actionBlockCache setObject:array forKey:timerName];
    }
}

- (void)removeActionCacheForTimer:(NSString *)timerName
{
    if (![self.actionBlockCache objectForKey:timerName])
        return;
    [self.actionBlockCache removeObjectForKey:timerName];
}

@end
