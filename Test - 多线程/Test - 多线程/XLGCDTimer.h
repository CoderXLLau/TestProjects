//
//  XLGCDTimer.h
//  Test - 多线程
//
//  Created by shannoon on 2017/6/29.
//  Copyright © 2017年 CoderXL. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  定时器附加操作
 */
typedef NS_ENUM(NSUInteger, XLActionOption){
    /**
     * 废除同一个timer之前的任务
     */
    XLActionOptionAbandonPreviousAction = 1,
    /**
     * 将同一个timer之前的任务合并到新的任务中
     */
    XLActionOptionMergePreviousAction = 2
};

@interface XLGCDTimer : NSObject

+ (XLGCDTimer *)sharedGCDTimer;

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
                             endAction:(dispatch_block_t)endAction;
/**
 启动一个timer，默认精度为0.1秒。
 
 @param timerName       timer的名称，作为唯一标识。
 @param interval        执行的时间间隔。
 @param queue           timer将被放入的队列，也就是最终action执行的队列。传入nil将自动放到一个子线程队列中。
 @param repeats         timer是否循环调用。
 @param option    多次schedule同一个timer时的操作选项(目前提供将之前的任务废除或合并的选项)。
 @param action          时间间隔到点时执行的block。
 */
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(double)interval
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                          actionOption:(XLActionOption)option
                                action:(dispatch_block_t)action;
/**
 撤销某个timer。
 
 @param timerName timer的名称，作为唯一标识。
 */
- (void)cancelTimerWithName:(NSString *)timerName;


/**
 *  是否存在某个名称标识的timer。
 *
 *  @param timerName timer的唯一名称标识。
 *
 *  @return YES表示存在，反之。
 */
- (BOOL)existTimer:(NSString *)timerName;

@end
