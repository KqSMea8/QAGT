//
//  GTMainThreadStackInfoGroup.h
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/25.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTMainThreadStackInfoGroup : NSObject
/*!
 * @brief 相同记录的堆栈信息重复的次数
 */
@property (nonatomic, assign) NSUInteger repeatCount;

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

@end

NS_ASSUME_NONNULL_END
