//
//  GTNormalInfoMonitor.h
//  MomoChat
//
//  Created by ChenZhen on 2018/12/5.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTRecordLogDelegate.h"

#define GTNormalInfoSharedManager [GTNormalInfoMonitor sharedInstance]

NS_ASSUME_NONNULL_BEGIN

@interface GTNormalInfoMonitor : NSObject

@property (nonatomic, weak) id<GTRecordLogDelegate> normalInfoDelegate;

+ (instancetype)sharedInstance;

- (void)startMonitor;
- (void)stopMonitor;

/**
 * @brief 返回要上传的基础性能信息字符串数组
 */
- (NSArray<NSString *> *)arrayForUpload;

@end

NS_ASSUME_NONNULL_END
