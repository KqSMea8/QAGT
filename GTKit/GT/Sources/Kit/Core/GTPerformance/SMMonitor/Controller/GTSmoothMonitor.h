//
//  GTSmoothMonitor.h
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/29.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTRecordLogDelegate.h"

#define GTSmoothSharedManager [GTSmoothMonitor sharedInstance]

NS_ASSUME_NONNULL_BEGIN

@interface GTSmoothMonitor : NSObject

@property (nonatomic, weak) id<GTRecordLogDelegate> smoothInfoDelegate;

+ (instancetype)sharedInstance;

- (void)startMonitor;
- (void)stopMonitor;

/**
 * @return 返回要上传的帧率信息字符串数组（字符串格式:序号^打点时间戳^frameCollect^帧率时间戳（屏幕每绘制一次，打一个时间戳））
 */
- (NSArray<NSString *> *)frameCollectForUpload;

@end

NS_ASSUME_NONNULL_END
