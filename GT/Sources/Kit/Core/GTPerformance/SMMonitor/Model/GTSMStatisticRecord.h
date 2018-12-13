//
//  GTSMStatisticRecord.h
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/29.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTSMStatisticRecord : NSObject
/*!
 * @brief 记录ID
 */
@property (nonatomic, assign) NSUInteger recordID;

/*!
 * @brief 记录时间戳
 */
@property (nonatomic, assign) NSTimeInterval recordTime;

/*!
 * @brief 屏幕刷新时间
 */
@property (nullable, nonatomic, strong) NSString *vSyncTime;

/*!
 * @brief 帧率信息
 */
- (nonnull NSString *)contentForUpload;

@end

NS_ASSUME_NONNULL_END
