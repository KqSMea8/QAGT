//
//  GTNormalInfoRecord.h
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/12/5.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTNormalInfoRecord : NSObject

/*!
 * @brief 记录ID
 */
@property (nonatomic, assign) NSUInteger recordID;

/*!
 * @brief 记录时间戳
 */
@property (nonatomic, assign) NSTimeInterval recordTime;

/*!
 * @brief CPU占用率
 */
@property (nonatomic, strong) NSString *cpuUsage;

/*!
 * @brief 线程信息
 */
@property (nonatomic, strong) NSString *threadInfo;

/*!
 * @brief Footprint Memory
 */
@property (nonatomic, strong) NSString *footPrintMemory;

/*!
 * @brief 上行流量
 */
@property (nonatomic, strong) NSString *transferStream;

/*!
 * @brief 下行流量
 */
@property (nonatomic, strong) NSString *receiveStream;

/*!
 * @brief 基础信息
 */
- (nonnull NSString *)contentForUpload;

@end

NS_ASSUME_NONNULL_END
