//
//  GTNormalInfoRecorder.m
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/12/5.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "GTNormalInfoRecorder.h"
#import "GTCPUUsage.h"
#import "GTNetTrafficModel.h"
#import "GTFootPrintModel.h"
#import "GTThreadInfoModel.h"

#import "GTNormalInfoRecord.h"
#import "GTLogQueue.h"
#import "GTUploadRecordId.h"

@interface GTNormalInfoRecorder ()
@property (nonatomic, strong) NSMutableArray<GTNormalInfoRecord *> *recordsArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *uploadArray;

@property (nonatomic, strong) GTCPUUsage *cpuModel;
@property (nonatomic, strong) GTFootPrintModel *footPrintModel;
@property (nonatomic, strong) GTNetTrafficModel *netModel;

@end

@implementation GTNormalInfoRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        _recordsArray = [NSMutableArray array];
        _uploadArray = [NSMutableArray array];
        
        _cpuModel = [[GTCPUUsage alloc] init];
        _footPrintModel = [[GTFootPrintModel alloc] init];
        _netModel = [[GTNetTrafficModel alloc] init];
    }
    return self;
}

- (void)recordNormalInfo {
    dispatch_async(logQueue(), ^{
        GTNormalInfoRecord *record = [[GTNormalInfoRecord alloc] init];
        record.recordID = [GTUploadRecordId sharedManager].uploadRecordId;
        record.recordTime = [[NSDate date] timeIntervalSince1970];
        record.cpuUsage = [_cpuModel cpuUsage];
        record.threadInfo = [GTThreadInfoModel allThreadInfos];
        record.footPrintMemory = [_footPrintModel residentMomory];
        record.transferStream = [_netModel transferStream];
        record.receiveStream = [_netModel receiveStream];
        [self.recordsArray addObject:record];

        // 写入MMFile
        NSString *content = [record contentForUpload];
        NSLog(@"normalInfo:%@", content);
        if ([self.normalInfoDelegate respondsToSelector:@selector(normalInfoLogHead:body:)]) {
            [self.normalInfoDelegate normalInfoLogHead:ProfileHead body:content ?: @""];
        }
    });
}

- (NSArray<NSString *> *)arrayForUpload {
    NSArray<GTNormalInfoRecord *> *recordsArray = [self.recordsArray copy];
    
    for (GTNormalInfoRecord *record in recordsArray) {
        @autoreleasepool {
            NSString *content = [record contentForUpload];
            [self.uploadArray addObject:content];
        }
    }
    
    NSArray *uploadArray = [self.uploadArray copy];
    
    dispatch_async(logQueue(), ^{
        [self clearAllUploadArray];
        [self clearAllRecords];
    });
    return uploadArray;
}

- (void)clear {
    dispatch_async(logQueue(), ^{
        [self clearAllUploadArray];
        [self clearAllRecords];
    });
}

- (void)clearAllRecords {
    if (self.recordsArray.count > 0) {
        self.recordsArray = [NSMutableArray array];
    }
}

- (void)clearAllUploadArray {
    if (self.uploadArray.count > 0) {
        self.uploadArray = [NSMutableArray array];
    }
}

@end
