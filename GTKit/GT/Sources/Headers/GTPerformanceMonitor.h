//
//  GTPerformanceMonitor.h
//  MomoChat
//
//  Created by ChenZhen on 2018/12/12.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTRecordLogDelegate.h"

#define GTPerformanceSharedManager [GTPerformanceMonitor sharedInstance]

NS_ASSUME_NONNULL_BEGIN

@interface GTPerformanceMonitor : NSObject

@property (nonatomic, weak) id<GTRecordLogDelegate> delegate;

+ (instancetype)sharedInstance;

/**
 * 开启性能监测，默认监测时间为30分钟
 */
- (void)startMonitor;

/**
 * 开启性能监测，监测时间为interval时长，单位为秒，最大监测时间为30分钟
 * @pram interval 监测时长
 */
- (void)startMonitorWithTimeInterval:(NSTimeInterval)interval;

@end

NS_ASSUME_NONNULL_END
