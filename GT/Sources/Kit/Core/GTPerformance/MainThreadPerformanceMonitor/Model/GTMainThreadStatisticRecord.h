//
//  GTMainThreadStatisticRecord.h
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/24.
//  Copyright © 2018 MoMo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTMainThreadStatisticRecord : NSObject

/*!
 * @brief 记录堆栈时所在的业务
 */
@property (nullable, nonatomic, copy) NSString *business;

/*!
 * @brief 记录ID
 */
@property (nonatomic, assign) NSUInteger recordID;

/*!
 * @brief 记录时间戳
 */
@property (nonatomic, assign) NSTimeInterval recordTime;

/*!
 * @brief 卡顿开始时间
 */
@property (nullable, nonatomic, strong) NSDate *blockStartTime;

/*!
 * @brief 卡顿结束时间
 */
@property (nullable, nonatomic, strong) NSDate *blockEndTime;

/*!
 * @brief 堆栈信息
 */
@property (nullable, nonatomic, strong) NSString *stackInfo;

/*!
 * @brief 堆栈信息md5
 */
@property (nullable, nonatomic, strong) NSString *stackInfoHash;

/*!
 * @brief 堆栈信息陌陌部分md5
 */
@property (nullable, nonatomic, strong) NSString *stackInfoInnerHash;

/*!
 * @brief 堆栈信息是否有陌陌部分
 */
@property (nonatomic, assign) BOOL isAppStackInfo;

/*!
 * @brief 当次记录线程数
 */
@property (nonatomic, assign) NSUInteger threadCount;

/*!
 * @brief 当前记录堆栈信息总采样个数
 */
@property (nonatomic, assign) NSUInteger totalSampleCount;

/*!
 * @brief 当前记录堆栈信息排名
 */
@property (nonatomic, assign) NSUInteger countRank;

/*!
 * @brief 相同记录的堆栈信息重复的次数
 */
@property (nonatomic, assign) NSUInteger repeatCount;

/*!
 * @brief 要上传的内容
 */
- (nonnull NSString *)contentForUpload;

@end

NS_ASSUME_NONNULL_END
