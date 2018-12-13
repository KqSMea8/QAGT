//
//  GTMainThreadRecorder.h
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/26.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMainThreadStackInfoGroup.h"
#import "GTMainThreadStatisticRecord.h"
#import "GTRecordLogDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GTMainThreadRecorder : NSObject

@property (nonatomic, weak) id<GTRecordLogDelegate> mainThreadInfoDelegate;

/**
 * 记录主线程堆栈相关的信息
 
 * @pram stackInfos 主线程堆栈信息的数组
 * @pram business 当前所在的业务类型
 * @pram blockStartTime 主线程阻塞开始发生的时间
 * @pram blockEndTime 记录主线程阻塞结束的时间
 */
- (void)recordMainThreadWithStackInfos:(NSArray<NSString *> *)stackInfos
                              business:(NSString *)business
                        blockStartTime:(NSDate *)blockStartTime
                          blockEndTime:(NSDate *)blockEndTime;

/**
 * @brief 停止记录，序号清零
 */
- (void)stopRecord;

/**
 * @brief 暂停记录，序号保留，记录数组清空
 */
- (void)pauseRecord;

/**
 * @brief 返回要上传的堆栈信息字符串数组
 */
- (NSArray<NSString *> *)arrayForUpload;



@end

NS_ASSUME_NONNULL_END
