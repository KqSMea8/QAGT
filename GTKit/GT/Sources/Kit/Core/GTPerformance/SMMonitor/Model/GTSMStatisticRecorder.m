//
//  GTSMStatisticRecorder.m
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/29.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "GTSMStatisticRecorder.h"
#import "GTSMStatisticRecord.h"
#import "GTLogQueue.h"
#import "GTUploadRecordId.h"

@interface GTSMStatisticRecorder ()
@property (nonatomic, strong) NSMutableArray<GTSMStatisticRecord *> *recordsArray;
@end

@implementation GTSMStatisticRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        _recordsArray = [NSMutableArray array];
    }
    
    return self;
}

- (void)recordFrameCollectWithRecordTime:(NSTimeInterval)recordTime
                               vSyncTime:(NSString *)vSyncTime {
    dispatch_async(logQueue(), ^{
        GTSMStatisticRecord *record = [[GTSMStatisticRecord alloc] init];
        record.recordTime = recordTime;
        record.vSyncTime = vSyncTime;
        record.recordID = [GTUploadRecordId sharedManager].uploadRecordId;
        if (!self.recordsArray) {
            self.recordsArray = [NSMutableArray array];
        }
        
        [self.recordsArray addObject:record];
        
        // 写入MMFile
        NSString *content = [record contentForUpload];
        NSLog(@"SMInfo:%@", content);
        if ([self.smoothInfoDelegate respondsToSelector:@selector(smoothLogHead:body:)]) {
            [self.smoothInfoDelegate smoothLogHead:ProfileHead body:content];
        }
        
    });
}

- (NSArray<NSString *> *)arrayForUpload {
    if (!self.recordsArray.count) {
        return nil;
    }
    
    NSArray *recordsArray = [self.recordsArray copy];
    [self.recordsArray removeAllObjects];
    NSMutableArray *array = [NSMutableArray array];
    for (GTSMStatisticRecord *record in recordsArray) {
        NSString *content = [record contentForUpload];
        [array addObject:content];
    }
    
    return [array copy];
}

@end
