//
//  GTDeviceCollectInfo.m
//  MomoChat
//
//  Created by ChenZhen on 2018/12/6.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "GTDeviceCollectInfo.h"
#import "GTAppInfo.h"
#import "GTLogQueue.h"

@implementation GTDeviceCollectInfo

+ (nonnull NSString *)contentForUpload {
    return [self deviceInfos];
}

// 序号^deviceCollect^厂商（iphone）^机型^系统sdk level（这个ios不用给）^系统版本号
+ (NSString *)deviceInfos {
    NSMutableString *deviceInfos = [NSMutableString string];
    
    NSString *recordId = @"1";
    NSDate *date = [NSDate date];
    NSTimeInterval recordTime = [date timeIntervalSince1970];
    NSString *recordTimeStamp = [NSString stringWithFormat:@"%lu", (NSUInteger)(recordTime * 1000)];
    NSString *deviceCollectMark = @"deviceCollect";
    NSString *separator = @"^";
    NSString *vendor = @"iPhone";    // 厂商
    NSString *deviceName = [GTAppInfo getDeviceName];    // 机型
    NSString *systemSdk = @"0";    // 这个iOS不用给
    NSString *systemVersion = [GTAppInfo getSystemVersion];    // 系统版本号
    [deviceInfos appendString:recordId];
    [deviceInfos appendString:separator];
    [deviceInfos appendString:recordTimeStamp];
    [deviceInfos appendString:separator];
    [deviceInfos appendString:deviceCollectMark];
    [deviceInfos appendString:separator];
    [deviceInfos appendString:vendor];
    [deviceInfos appendString:separator];
    [deviceInfos appendString:deviceName];
    [deviceInfos appendString:separator];
    [deviceInfos appendString:systemSdk];
    [deviceInfos appendString:separator];
    [deviceInfos appendString:systemVersion];
    NSLog(@"deviceInfos:%@", deviceInfos);
    return [deviceInfos copy];
}

@end
