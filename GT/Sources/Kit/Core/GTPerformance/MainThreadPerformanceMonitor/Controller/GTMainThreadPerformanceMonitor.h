//
//  GTMainThreadPerformanceMonitor.h
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/24.
//  Copyright © 2018 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTRecordLogDelegate.h"

NS_ASSUME_NONNULL_BEGIN

#define GTMainThreadSharedMonitor [GTMainThreadPerformanceMonitor sharedInstance]

@interface GTMainThreadPerformanceMonitor : NSObject

@property (nonatomic, weak) id<GTRecordLogDelegate> mainThreadInfoDelegate;

+ (instancetype)sharedInstance;

- (void)startMonitor;
- (void)stopMonitor;

/**
 * @return 返回要上传的堆栈信息字符串数组（字符串格式:序号+打点时间戳+stackCollect+^+卡顿信息+^+卡顿时间戳）
 */
- (NSArray<NSString *> *)arrayForUpload;

@end

NS_ASSUME_NONNULL_END
