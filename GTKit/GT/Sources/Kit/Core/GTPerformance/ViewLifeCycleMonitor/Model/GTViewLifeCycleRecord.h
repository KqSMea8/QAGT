//
//  GTViewLifeCycleRecord.h
//  MomoChat
//
//  Created by ChenZhen on 2018/11/29.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTViewLifeCycleRecord : NSObject
- (nonnull NSString *)viewLifeCycleInfoForUpload;

/*!
 * @brief 记录当前页面名称
 */
@property (nullable, nonatomic, copy) NSString *business;

/*!
 * @brief 页面的哈希值
 */
@property (nullable, nonatomic, strong) NSString *viewHashCode;

/*!
 * @brief 页面所处的周期
 */
@property (nullable, nonatomic, strong) NSString *viewLifeState;

/*!
 * @brief 记录ID
 */
@property (nonatomic, assign) NSUInteger recordID;

/*!
 * @brief 记录时间戳
 */
@property (nonatomic, assign) NSTimeInterval recordTime;

/*!
 * @brief 页面开始时间
 */
@property (nullable, nonatomic, strong) NSDate *viewAppearTime;

/*!
 * @brief 页面结束时间
 */
@property (nullable, nonatomic, strong) NSDate *viewDisappearTime;

@property (nonatomic, assign) NSUInteger index;

@end

NS_ASSUME_NONNULL_END
