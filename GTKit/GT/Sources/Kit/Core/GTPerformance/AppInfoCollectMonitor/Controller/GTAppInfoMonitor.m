//
//  GTAppInfoMonitor.m
//  MomoChat
//
//  Created by ChenZhen on 2018/12/6.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "GTAppInfoMonitor.h"
#import "GTAppCollectInfo.h"
#import "GTDeviceCollectInfo.h"

#import "GTLogQueue.h"

@interface GTAppInfoMonitor ()
@property (nonatomic, assign) BOOL isMonitoring;
@end

@implementation GTAppInfoMonitor

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GTAppInfoMonitor *sharedSingleton = nil;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return sharedSingleton;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)copy {
    return self;
}

- (instancetype)mutableCopy {
    return self;
}

#define mark - Public
- (void)startMonitor {
    if (_isMonitoring) { return; }
    _isMonitoring = YES;
    
    dispatch_async(logQueue(), ^{
        // 写入MMFile
        NSString *appInfo = [GTAppCollectInfo contentForUpload];
        if ([self.appInfoDelegate respondsToSelector:@selector(appInfoLogHead:body:)]) {
            [self.appInfoDelegate appInfoLogHead:ProfileHead body:appInfo ?: @""];
        }
        
        NSString *deviceInfo = [GTDeviceCollectInfo contentForUpload];
        if ([self.deviceInfoDelegate respondsToSelector:@selector(deviceInfoLogHead:body:)]) {
            [self.deviceInfoDelegate deviceInfoLogHead:ProfileHead body:deviceInfo ?: @""];
        }
        
    });
}

- (void)stopMonitor {
    if (!_isMonitoring) { return; };
    _isMonitoring = NO;
    
}

@end
