//
//  GTAppCollectInfo.m
//  MomoChat
//
//  Created by ChenZhen on 2018/12/3.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "GTAppCollectInfo.h"
#import "GTAppInfo.h"
#import "BSBacktraceLogger.h"
#import "GTMTA.h"

@implementation GTAppCollectInfo

+ (nonnull NSString *)contentForUpload {
    return [self appInfos];
}

// appCollect+包名+应用名称+应用版本号（大版本号）+内部版本号+gtsdk版本号+开始采集时间+主线程id
+ (NSString *)appInfos {
    NSMutableString *appInfos = [NSMutableString string];
    
    NSString *recordId = @"0";
    NSDate *date = [NSDate date];
    NSTimeInterval recordTime = [date timeIntervalSince1970];
    NSString *recordTimeStamp = [NSString stringWithFormat:@"%lu", (NSUInteger)(recordTime * 1000)];
    NSString *appCollectMark = @"appCollect";
    NSString *separator = @"^";
    NSString *packageName = @"";
    NSString *appName = [GTAppInfo getAppName];
    NSString *innerAppVersion = [GTAppInfo getInnerAppVersion];
    NSString *appVersion = [GTAppInfo getAPPVerion];
    //FIXME:临时数据。引用GT的宏来获取MTA_SDK_VERSION
    NSString *gtVersion = MTA_SDK_VERSION;
    NSString *mainThreadId = [BSBacktraceLogger mianThreadId];
    [appInfos appendString:recordId];
    [appInfos appendString:separator];
    [appInfos appendString:recordTimeStamp];
    [appInfos appendString:separator];
    [appInfos appendString:appCollectMark];
    [appInfos appendString:separator];
    [appInfos appendString:packageName];
    [appInfos appendString:separator];
    [appInfos appendString:appName];
    [appInfos appendString:separator];
    [appInfos appendString:appVersion];
    [appInfos appendString:separator];
    [appInfos appendString:innerAppVersion];
    [appInfos appendString:separator];
    [appInfos appendString:gtVersion];
    [appInfos appendString:separator];
    [appInfos appendString:recordTimeStamp];
    [appInfos appendString:separator];
    [appInfos appendString:mainThreadId];
    NSLog(@"AppCollectInfo:%@", appInfos);
    return [appInfos copy];
}

@end
