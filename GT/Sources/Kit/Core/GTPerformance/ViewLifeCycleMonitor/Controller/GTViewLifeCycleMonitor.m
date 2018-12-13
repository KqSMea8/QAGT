//
//  GTViewLifeCycleMonitor.m
//  MomoChat
//
//  Created by ChenZhen on 2018/12/1.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "GTViewLifeCycleMonitor.h"
#import "GTViewLifeCycleRecorder.h"

@interface GTViewLifeCycleMonitor ()
@property (nonatomic, assign) BOOL isMonitoring;
@property (nonatomic, strong) GTViewLifeCycleRecorder *vlcRecorder;
@end

@implementation GTViewLifeCycleMonitor
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GTViewLifeCycleMonitor *sharedSingleton = nil;
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
    _vlcRecorder = [[GTViewLifeCycleRecorder alloc] init];
}

#define mark - Public
- (void)startMonitor {
    if (_isMonitoring) { return; }
    _isMonitoring = YES;
    
}

- (void)stopMonitor {
    if (!_isMonitoring) { return; };
    _isMonitoring = NO;
    
    [self clearAllRecords];
}

- (void)clearAllRecords {
    [self.vlcRecorder clear];
}

- (void)recordBusiness:(NSString *)business
      businessHashCode:(NSString *)hashCode
    viewStateBeginTime:(NSDate *)beginTime
      viewStateEndTime:(NSDate *)endTime
         viewLifeState:(NSString *)state {
    if (!_isMonitoring) { return; };
    [self.vlcRecorder recordBusiness:business
                    businessHashCode:hashCode
                  viewStateBeginTime:beginTime
                    viewStateEndTime:endTime
                       viewLifeState:state];
}


- (NSArray<NSString *> *)viewLifeCycleArrayForUpload {
    NSArray *array = [self.vlcRecorder arrayForUpload];
    return array;
}

#pragma mark - Getter,Setter
- (void)setViewLifeCycleDelegate:(id<GTRecordLogDelegate>)viewLifeCycleDelegate {
    if (_vlcRecorder.viewLifeCycleDelegate == viewLifeCycleDelegate) {
        return;
    }
    
    _vlcRecorder.viewLifeCycleDelegate = viewLifeCycleDelegate;
}
@end
