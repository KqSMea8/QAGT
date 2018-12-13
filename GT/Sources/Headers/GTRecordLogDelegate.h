//
//  GTRecordLogDelegate.h
//  MomoChat
//
//  Created by ChenZhen on 2018/12/6.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ProfileHead @"profiler"

NS_ASSUME_NONNULL_BEGIN

@protocol GTRecordLogDelegate <NSObject>

- (void)appInfoLogHead:(NSString *)head body:(NSString *)body;
- (void)deviceInfoLogHead:(NSString *)head body:(NSString *)body;
- (void)normalInfoLogHead:(NSString *)head body:(NSString *)body;
- (void)viewLifeCycleLogHead:(NSString *)head body:(NSString *)body;
- (void)smoothLogHead:(NSString *)head body:(NSString *)body;
- (void)mainThreadLogHead:(NSString *)head body:(NSString *)body;

/*!
 * @brief 标记采集已结束的Log信息，没有记录该结束信息，服务器会将本次性能监测数据全部丢掉
 */
- (void)pageStopInfoLogHead:(NSString *)head body:(NSString *)body;
- (void)appStopCollectInfoLogHead:(NSString *)head body:(NSString *)body;

@end

NS_ASSUME_NONNULL_END
