//
//  GTNormalInfoMonitor.m
//  MomoChat
//
//  Created by ChenZhen on 2018/12/5.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "GTNormalInfoMonitor.h"
#import "GTNormalInfoRecorder.h"

@interface GTNormalInfoMonitor ()
@property (nonatomic, assign) BOOL isMonitoring;
@property (nonatomic, strong) GTNormalInfoRecorder *normRecorder;

@property (nonatomic, strong) NSTimer *norInfoTimer;
@end

@implementation GTNormalInfoMonitor

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GTNormalInfoMonitor *sharedSingleton = nil;
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
    _normRecorder = [[GTNormalInfoRecorder alloc] init];
}

#define mark - Public
- (void)startMonitor {
    if (_isMonitoring) { return; }
    _isMonitoring = YES;
    
    __weak GTNormalInfoMonitor *weakSelf = self;
    self.norInfoTimer = [NSTimer timerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf recordNormalInfo];
        NSLog(@"timer fire" );
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.norInfoTimer forMode:NSRunLoopCommonModes];
}

- (void)stopMonitor {
    if (!_isMonitoring) { return; };
    _isMonitoring = NO;
    
    [self clearAllRecords];
    [self clearTimer];
}

- (void)clearAllRecords {
    [self.normRecorder clear];
}

- (void)clearTimer {
    [self.norInfoTimer invalidate];
    self.norInfoTimer = nil;
}

- (void)recordNormalInfo {
    if (!_isMonitoring) { return; };
    [self.normRecorder recordNormalInfo];
}

- (NSArray<NSString *> *)arrayForUpload {
    NSArray *array = [self.normRecorder arrayForUpload];
    return array;
}

#pragma mark - Getter, Setter
- (void)setNormalInfoDelegate:(id<GTRecordLogDelegate>)normalInfoDelegate {
    if (_normRecorder.normalInfoDelegate == normalInfoDelegate) {
        return;
    }
    
    _normRecorder.normalInfoDelegate = normalInfoDelegate;
}
@end
