//
//  GTPerformanceMonitor.m
//  MomoChat
//
//  Created by ChenZhen on 2018/12/12.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "GTPerformanceMonitor.h"

#import "GTAppInfoMonitor.h"
#import "GTNormalInfoMonitor.h"
#import "GTMainThreadPerformanceMonitor.h"
#import "GTSmoothMonitor.h"
#import "GTViewLifeCycleMonitor.h"

#import "GTLogQueue.h"
#import "GTUploadRecordId.h"

@implementation GTPerformanceMonitor

#pragma mark - Singleton
+ (instancetype)sharedInstance {
    static GTPerformanceMonitor *sharedSingleton = nil;
    static dispatch_once_t onceToken;
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

#pragma mark - Public

- (void)startMonitor {
    [self startMonitorWithTimeInterval:(30 * 60)];
}

- (void)startMonitorWithTimeInterval:(NSTimeInterval)interval {
    NSAssert(self.delegate, @"Please set \"GTRecordLogDelegate\"");
    if (!self.delegate) { return; };
    interval = interval <= 30 * 60 ? interval : 30 * 60;
    [self wireDelegation];
    [GTAppInfoSharedManager startMonitor];
    [GTSmoothSharedManager startMonitor];
    [GTViewLifeCycleSharedManager startMonitor];
    [GTMainThreadSharedMonitor startMonitor];
    [GTNormalInfoSharedManager startMonitor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), logQueue(), ^{
        [self stopMonitor];
    });
}

- (void)stopMonitor {
    [self recordEndLogInfo];
    [GTAppInfoSharedManager stopMonitor];
    [GTSmoothSharedManager stopMonitor];
    [GTViewLifeCycleSharedManager stopMonitor];
    [GTMainThreadSharedMonitor stopMonitor];
    [GTNormalInfoSharedManager stopMonitor];
}

- (void)wireDelegation {
    if (!self.delegate) {
        return;
    }
    
    GTAppInfoSharedManager.appInfoDelegate = self.delegate;
    GTAppInfoSharedManager.deviceInfoDelegate = self.delegate;
    GTSmoothSharedManager.smoothInfoDelegate = self.delegate;
    GTViewLifeCycleSharedManager.viewLifeCycleDelegate = self.delegate;
    GTMainThreadSharedMonitor.mainThreadInfoDelegate = self.delegate;
    GTNormalInfoSharedManager.normalInfoDelegate = self.delegate;
}

- (void)recordEndLogInfo {
    if ([self.delegate respondsToSelector:@selector(pageStopInfoLogHead:body:)]) {
        [self.delegate pageStopInfoLogHead:ProfileHead body:[self pageStopLogInfo]];
    }
    if ([self.delegate respondsToSelector:@selector(appStopCollectInfoLogHead:body:)]) {
        [self.delegate appStopCollectInfoLogHead:ProfileHead body:[self appStopCollectLogInfo]];
    }
}

- (NSString *)pageStopLogInfo {
    NSString *time = [@((NSUInteger)([[NSDate date] timeIntervalSince1970] * 1000)) stringValue];
    NSString *content = [NSString stringWithFormat:@"%lu^%@^viewWillDisappear^pageStop^%@^%@^%@", (unsigned long)[GTUploadRecordId sharedManager].uploadRecordId, time, [@([@"pageStop" hash]) stringValue], time, time];
    
    return content;
}

- (NSString *)appStopCollectLogInfo {
    NSString *time = [@((NSUInteger)([[NSDate date] timeIntervalSince1970] * 1000)) stringValue];
    NSString *content = [NSString stringWithFormat:@"%lu^%@^appStopCollect^%@",(unsigned long)[GTUploadRecordId sharedManager].uploadRecordId, time, time];
    return content;
}

@end
