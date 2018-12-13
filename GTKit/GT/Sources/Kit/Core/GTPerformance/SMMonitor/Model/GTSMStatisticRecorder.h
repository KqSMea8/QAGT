//
//  GTSMStatisticRecorder.h
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/29.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTRecordLogDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GTSMStatisticRecorder : NSObject

@property (nonatomic, weak) id<GTRecordLogDelegate> smoothInfoDelegate;

/**
 * 记录帧率相关的信息
 
 * @pram recordTime 打点时间戳
 * @pram vSyncTime 帧率时间戳
 */
- (void)recordFrameCollectWithRecordTime:(NSTimeInterval)recordTime
                          vSyncTime:(NSString *)vSyncTime;

/**
 * @brief 停止记录，序号清零
 */
- (void)stopRecord;

/**
 * @brief 返回要上传的vSync字符串数组
 */
- (NSArray<NSString *> *)arrayForUpload;

@end

NS_ASSUME_NONNULL_END
