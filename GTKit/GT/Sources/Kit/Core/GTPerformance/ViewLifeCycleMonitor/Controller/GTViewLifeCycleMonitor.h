//
//  GTViewLifeCycleMonitor.h
//  MomoChat
//
//  Created by ChenZhen on 2018/12/1.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTRecordLogDelegate.h"

#define GTViewLifeCycleSharedManager [GTViewLifeCycleMonitor sharedInstance]

NS_ASSUME_NONNULL_BEGIN

@interface GTViewLifeCycleMonitor : NSObject

@property (nonatomic, weak) id<GTRecordLogDelegate> viewLifeCycleDelegate;

+ (instancetype)sharedInstance;

- (void)startMonitor;
- (void)stopMonitor;

/**
 * 记录控制器生命周期相关的信息
 
 * @pram business 当前控制器
 * @pram hashCode 当前所在控制器的哈希值
 * @pram viewStateBeginTime 每个阶段的开时时间
 * @pram viewStateEndTime 每个阶段的结束时间
 * @pram viewLifeState 控制器生命周期的各个阶段
 */
- (void)recordBusiness:(NSString *)business
      businessHashCode:(NSString *)hashCode
    viewStateBeginTime:(NSDate *)beginTime
      viewStateEndTime:(NSDate *)endTime
         viewLifeState:(NSString *)state;

- (NSArray<NSString *> *)viewLifeCycleArrayForUpload;

@end

NS_ASSUME_NONNULL_END
