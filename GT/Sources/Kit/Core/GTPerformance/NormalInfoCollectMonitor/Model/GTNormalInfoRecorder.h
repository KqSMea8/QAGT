//
//  GTNormalInfoRecorder.h
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/12/5.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTRecordLogDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GTNormalInfoRecorder : NSObject

@property (nonatomic, weak) id<GTRecordLogDelegate> normalInfoDelegate;

/**
 * 记录基础性能信息
 
*/
- (void)recordNormalInfo;

/**
 * @brief 返回要上传的基础性能信息字符串数组
 */
- (NSArray<NSString *> *)arrayForUpload;

- (void)clear;
@end

NS_ASSUME_NONNULL_END
