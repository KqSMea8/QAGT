//
//  GTMainThreadPerformanceMonitor.m
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/24.
//  Copyright © 2018 MoMo. All rights reserved.
//

#import "GTMainThreadPerformanceMonitor.h"
#import "BSBacktraceLogger.h"
#import "GTMainThreadRecorder.h"

#import "NSString+MD5.h"
#import "GTMainThreadStackInfoGroup.h"
#import "GTMainThreadStatisticRecord.h"

@interface GTMainThreadPerformanceMonitor ()

/*!
 *  @brief 管理记录堆栈信息
 */
@property (nonatomic, strong) GTMainThreadRecorder *recorder;

@property (nonatomic, assign) BOOL isMonitoring;
@property (nonatomic, assign) CFRunLoopObserverRef runLoopObserver;
@property (nonatomic, assign) CFRunLoopActivity currentActivity;
@property (nonatomic, assign) NSInteger timeOut;

/*!
 *  @brief 连续卡顿信号量
 */
@property (nonatomic, strong) dispatch_semaphore_t semphore;

/*!
 *  @brief 单次耗时较长卡顿信号量
 */
@property (nonatomic, strong) dispatch_semaphore_t eventSemphore;

@end

#define WAIT_SEMPHORE_SUCCESS 0
static const NSTimeInterval timeOutInterval = 1;
static const int64_t waitInterval = 50 * NSEC_PER_MSEC;

/*!
 *  @brief 监控连续卡顿的队列
 */
static inline dispatch_queue_t fluecyMonitorQueue() {
    static dispatch_queue_t fluecyMonitorQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fluecyMonitorQueue = dispatch_queue_create("com.momo.performanceMonitor.fluecyMonitorQueue", NULL);
    });
    return fluecyMonitorQueue;
}

/*!
 *  @brief 监控单次耗时较长卡顿的队列
 */
static inline dispatch_queue_t eventMonitorQueue() {
    static dispatch_queue_t eventMonitorQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eventMonitorQueue = dispatch_queue_create("com.momo.performanceMonitor.eventMonitorQueue", NULL);
    });
    return eventMonitorQueue;
}

#define LOG_RUNLOOP_ACTIVITY 0
static void runLoopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void * info) {
    GTMainThreadSharedMonitor.currentActivity = activity;
    dispatch_semaphore_signal(GTMainThreadSharedMonitor.semphore);
    
#if LOG_RUNLOOP_ACTIVITY
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"🚀runloop entry");
            break;
            
        case kCFRunLoopExit:
            NSLog(@"🚀runloop exit");
            break;
            
        case kCFRunLoopAfterWaiting:
            NSLog(@"🚀runloop after waiting");
            break;
            
        case kCFRunLoopBeforeTimers:
            NSLog(@"🚀runloop before timers");
            break;
            
        case kCFRunLoopBeforeSources:
            NSLog(@"🚀runloop before sources");
            break;
            
        case kCFRunLoopBeforeWaiting:
            NSLog(@"🚀runloop before waiting");
            break;
            
        default:
            break;
    }
#endif
}

@implementation GTMainThreadPerformanceMonitor

#pragma mark - Singleton
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GTMainThreadPerformanceMonitor *sharedSingleton = nil;
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
    self.semphore = dispatch_semaphore_create(0);
    self.eventSemphore = dispatch_semaphore_create(0);
    
    _recorder = [[GTMainThreadRecorder alloc] init];
}

#define mark - Public

- (NSArray<NSString *> *)arrayForUpload {
    NSArray *array = [self.recorder arrayForUpload];
    return array;
}


- (void)startMonitor {
    if (_isMonitoring) { return; }
    _isMonitoring = YES;
    
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)self,
        NULL,
        NULL
    };
    
    _runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runLoopObserverCallback, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _runLoopObserver, kCFRunLoopCommonModes);

    dispatch_async(eventMonitorQueue(), ^{
        NSDate *blockStartTime = nil;
        NSMutableArray<NSString *> *stackInfos = [NSMutableArray array];
        while (GTMainThreadSharedMonitor.isMonitoring) {

            if (GTMainThreadSharedMonitor.currentActivity == kCFRunLoopBeforeWaiting) {
                __block BOOL timeOut = YES;
                blockStartTime = [NSDate date];
                dispatch_async(dispatch_get_main_queue(), ^{
                    timeOut = NO;
                    dispatch_semaphore_signal(GTMainThreadSharedMonitor.eventSemphore);
                });
                [NSThread sleepForTimeInterval:timeOutInterval];
                
                // 超时，记录卡顿信息
                if (timeOut) {
                    NSDate *blockEndTime = [NSDate date];
                    if (!stackInfos) {
                        stackInfos = [NSMutableArray array];
                    }
                    NSLog(@"事件卡顿");

                    [stackInfos addObject:[BSBacktraceLogger bs_backtraceOfMainThread]];
                    NSString *business = nil;
                    [self.recorder recordMainThreadWithStackInfos:stackInfos business:business blockStartTime:blockStartTime blockEndTime:blockEndTime];
                } else {
                    blockStartTime = nil;
                }
            }
        }
    });
    
    dispatch_async(fluecyMonitorQueue(), ^{
        NSDate *blockStartTime = nil;
        NSMutableArray<NSString *> *stackInfos = [NSMutableArray array];

        while (GTMainThreadSharedMonitor.isMonitoring) {
            long waitTime = dispatch_semaphore_wait(self.semphore, dispatch_time(DISPATCH_TIME_NOW, waitInterval));
            if (waitTime != WAIT_SEMPHORE_SUCCESS) {
                if (!GTMainThreadSharedMonitor.runLoopObserver) {
                    GTMainThreadSharedMonitor.timeOut = 0;
                    [GTMainThreadSharedMonitor stopMonitor];
                    continue;
                }
                if (GTMainThreadSharedMonitor.currentActivity == kCFRunLoopBeforeSources ||
                    GTMainThreadSharedMonitor.currentActivity == kCFRunLoopAfterWaiting) {
                    if (++GTMainThreadSharedMonitor.timeOut < 5) {
                        if (GTMainThreadSharedMonitor.timeOut == 1) {
                            blockStartTime = [NSDate date];
                        }
                        if (!stackInfos) {
                            stackInfos = [NSMutableArray array];
                        }
                        [stackInfos addObject:[BSBacktraceLogger bs_backtraceOfMainThread]];
                        continue;
                    }
                    NSLog(@"连续卡顿");
                    NSDate *blockEndTime = [NSDate date];
                    NSString *business = nil;
                    [stackInfos addObject:[BSBacktraceLogger bs_backtraceOfMainThread]];
                    [self.recorder recordMainThreadWithStackInfos:stackInfos business:business blockStartTime:blockStartTime blockEndTime:blockEndTime];
                }
            }
            GTMainThreadSharedMonitor.timeOut = 0;
            stackInfos = nil;
            blockStartTime = nil;
        }
    });
}

- (void)stopMonitor {
    if (!_isMonitoring) { return; };
    _isMonitoring = NO;

    __weak GTMainThreadPerformanceMonitor *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong GTMainThreadPerformanceMonitor *strongSelf = weakSelf;
        [strongSelf removeRunLoopObserver];
    });
    
    [self.recorder stopRecord];
}

#pragma mark - Getter,Setter

- (void)setMainThreadInfoDelegate:(id<GTRecordLogDelegate>)mainThreadInfoDelegate {
    if (_recorder.mainThreadInfoDelegate == mainThreadInfoDelegate) {
        return;
    }
    
    _recorder.mainThreadInfoDelegate = mainThreadInfoDelegate;
}

#pragma mark - Private
- (void)removeRunLoopObserver {
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _runLoopObserver, kCFRunLoopCommonModes);
    CFRelease(_runLoopObserver);
    _runLoopObserver = NULL;
}

@end
