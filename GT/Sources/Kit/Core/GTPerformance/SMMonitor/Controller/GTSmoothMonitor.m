//
//  GTSmoothMonitor.m
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/29.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "GTSmoothMonitor.h"
#import <UIKit/UIKit.h>
#import "GTSMStatisticRecorder.h"

@interface GTSmoothMonitor ()
@property (nonatomic, assign) BOOL isMonitoring;
@property (nonatomic, strong) GTSMStatisticRecorder *smRecorder;
@property (nullable, nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSUInteger lastTime;

@end

@implementation GTSmoothMonitor

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GTSmoothMonitor *sharedSingleton = nil;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[super allocWithZone:NULL] init];
        [sharedSingleton commonInit];
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

- (void)dealloc {
    [self stopMonitor];
}

- (void)commonInit {
    _smRecorder = [[GTSMStatisticRecorder alloc] init];
}

#define mark - Public
- (void)startMonitor {
    if (_isMonitoring) { return; }
    _isMonitoring = YES;
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopMonitor {
    if (!_isMonitoring) { return; };
    _isMonitoring = NO;
    
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)displayLinkTick:(nonnull CADisplayLink *)link {
    if (!self.displayLink) {
        return;
    }
    NSUInteger vSyncTime = (NSUInteger)([[NSDate date] timeIntervalSince1970] * 1000);
    
    if (self.lastTime == vSyncTime) {
        return;
    }
    self.lastTime = vSyncTime;
    [self.smRecorder recordFrameCollectWithRecordTime:[[NSDate date] timeIntervalSince1970] vSyncTime:[@(vSyncTime) stringValue]];
}

- (NSArray<NSString *> *)frameCollectForUpload {
    NSArray *array = [self.smRecorder arrayForUpload];
    return array;
}

#pragma mark - Getter,Setter
- (void)setSmoothInfoDelegate:(id<GTRecordLogDelegate>)smoothInfoDelegate {
    if (_smRecorder.smoothInfoDelegate == smoothInfoDelegate) {
        return;
    }
    
    _smRecorder.smoothInfoDelegate = smoothInfoDelegate;
}

@end
