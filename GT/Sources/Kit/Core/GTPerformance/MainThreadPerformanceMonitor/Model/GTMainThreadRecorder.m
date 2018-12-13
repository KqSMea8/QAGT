//
//  GTMainThreadRecorder.m
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/26.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "GTMainThreadRecorder.h"
#import "GTLogQueue.h"
#import "GTUploadRecordId.h"
#import "NSString+MD5.h"

@interface GTMainThreadRecorder ()

/*!
 *  @brief 上传记录的序号(从0开始)
 */
@property (nonatomic, assign) NSUInteger recordNum;

@property (nonatomic, strong) NSMutableArray<NSString *> *uploadArray;
@property (nonatomic, strong) NSMutableArray<GTMainThreadStatisticRecord *> *recordsArray;
@property (nullable, nonatomic, strong) NSArray<NSString *> *lastUploadArray;

@end

@implementation GTMainThreadRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        _recordsArray = [NSMutableArray array];
        _recordNum = 0;
        _uploadArray = [NSMutableArray array];
    }
    
    return self;
}

- (void)recordMainThreadWithStackInfos:(NSArray<NSString *> *)stackInfos
                              business:(NSString *)business
                        blockStartTime:(NSDate *)blockStartTime
                          blockEndTime:(NSDate *)blockEndTime {
    dispatch_async(logQueue(), ^{
        NSUInteger totalCount = stackInfos.count;
        NSMutableDictionary<NSString *, GTMainThreadStackInfoGroup *> *groups = [NSMutableDictionary dictionary];
        
        for (NSString *stackInfo in stackInfos) {
            @autoreleasepool {
                NSArray<NSString *> *infoLines = [stackInfo componentsSeparatedByString:@"\n"];
                NSMutableString *groupStackInfo = [NSMutableString string];
                NSMutableString *innerStackInfo = [NSMutableString string];
                BOOL exisInnerPerfix = NO;
                BOOL innerStackEnd = NO;
                BOOL firstGroupLine = YES;
                BOOL firstInnerLine = YES;
                
                for (NSUInteger i = 0; i < infoLines.count; i++) {
                    @autoreleasepool {
                        if (i == 0) {
                            // 忽略“Backtrace of Thread 771:”
                            continue;
                        }
                        NSString *infoLine = infoLines[i];
                        if (infoLine.length < 0) {
                            continue;
                        }
                        NSArray<NSString *> *parts = [infoLine componentsSeparatedByString:@" "];
                        if (parts.count <= 0) {
                            continue;
                        }
                        NSMutableString *groupLine = [NSMutableString string];
                        NSUInteger notEmptyPartCount = 0;
                        BOOL firstPart = YES;
                        for (NSUInteger j = 0; j < parts.count; j++) {
                            NSString *part = parts[j];
                            if (part.length > 0) {
                                if (++notEmptyPartCount == 2) {
                                    // 过滤掉虚拟地址一列信息
                                    continue;
                                }
                            }
                            if (!firstPart) {
                                [groupLine appendString:@" "];
                            }
                            firstPart = NO;
                            [groupLine appendString:part];
                        }
                        
                        if (!firstGroupLine) {
                            [groupStackInfo appendString:@"\n"];
                        }
                        firstGroupLine = NO;
                        [groupStackInfo appendString:groupLine];
                        
                        // 由第一组app名开头的连续行作为innerStackInfo
                        if (!innerStackEnd && [parts[0] isEqualToString:@"MomoChat"]) {
                            exisInnerPerfix = YES;
                            if (!firstInnerLine) {
                                [innerStackInfo appendString:@"\n"];
                            }
                            firstInnerLine = NO;
                            [innerStackInfo appendString:groupLine];
                        } else if (exisInnerPerfix) {
                            innerStackEnd = YES;
                        }
                    }
                }
                
                NSString *key = nil;
                NSString *stackInfoHash = nil;
                NSString *stackInfoInnerHash = nil;
                if (exisInnerPerfix) {
                    stackInfoInnerHash = [innerStackInfo UTF8String] ? [innerStackInfo md5String] : nil;
                    key = stackInfoInnerHash;
                } else {
                    stackInfoHash = [groupStackInfo UTF8String] ? [groupStackInfo md5String] : nil;
                    key = stackInfoHash;
                }
                if (!key) {
                    key = [stackInfo UTF8String] ? [stackInfo md5String] : nil;
                }
                if (!key) {
                    continue;
                }
                
                GTMainThreadStackInfoGroup *group = groups[key];
                if (group) {
                    group.repeatCount++;
                } else {
                    group = [[GTMainThreadStackInfoGroup alloc] init];
                    group.stackInfo = stackInfo;
                    group.stackInfoHash = stackInfoHash ?: ([groupStackInfo UTF8String] ? [groupStackInfo md5String] : nil);
                    group.stackInfoInnerHash = stackInfoInnerHash ?: ([innerStackInfo UTF8String] ? [innerStackInfo md5String] : nil);
                    group.isAppStackInfo = exisInnerPerfix;
                    group.repeatCount = 1;
                    groups[key] = group;
                }
            }
        }
        
        NSArray<NSString *> *keys = [groups keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return ((GTMainThreadStackInfoGroup *)obj1).repeatCount >= ((GTMainThreadStackInfoGroup *)obj2).repeatCount ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        NSUInteger counRank = 0;
        NSUInteger prevCount = 0;
        for (NSString *key in keys) {
            @autoreleasepool {
                GTMainThreadStackInfoGroup *group = groups[key];
                GTMainThreadStatisticRecord *record = [[GTMainThreadStatisticRecord alloc] init];
                record.business = business;
                record.blockStartTime = blockStartTime;
                record.blockEndTime = blockEndTime;
                record.stackInfo = group.stackInfo;
                record.stackInfoHash = group.stackInfoHash;
                record.stackInfoInnerHash = group.stackInfoInnerHash;
                record.isAppStackInfo = group.isAppStackInfo;
                record.repeatCount = group.repeatCount;
                record.totalSampleCount = totalCount;
                record.countRank = prevCount == group.repeatCount ? counRank : ++counRank;
                record.recordID = [GTUploadRecordId sharedManager].uploadRecordId;
                record.recordTime = [[NSDate date] timeIntervalSince1970];
                prevCount = group.repeatCount;
                
                [self.recordsArray addObject:record];
                
                // 写入MMFile
                NSString *content = [record contentForUpload];
                NSLog(@"mainThread:%@", content);
                if ([self.mainThreadInfoDelegate respondsToSelector:@selector(mainThreadLogHead:body:)]) {
                    [self.mainThreadInfoDelegate mainThreadLogHead:ProfileHead body:content];
                }
            }
        }
    });
}

- (void)stopRecord {
    [self destroyAllRecords];
    self.recordNum = 0;
}

- (void)destroyAllRecords {
    self.recordsArray = nil;
}

- (void)pauseRecord {
    [self clearAllRecords];
}

- (void)clearAllRecords {
    if (self.recordsArray.count > 0) {
        self.recordsArray = [NSMutableArray array];
    }
}

- (void)clearAllUploadArray {
    if (self.uploadArray.count > 0) {
        [self.uploadArray removeAllObjects];
    }
}

- (NSArray<NSString *> *)arrayForUpload {
    
    NSArray<GTMainThreadStatisticRecord *> *recordsArray = [self.recordsArray copy];
    
    for (GTMainThreadStatisticRecord *record in recordsArray) {
        @autoreleasepool {
            NSString *content = [record contentForUpload];
            [self.uploadArray addObject:content];
        }
    }
    
//    dispatch_sync(blockInfoLogQueue(), ^{
//        for (GTMainThreadStatisticRecord *record in self.recordsArray) {
//            @autoreleasepool {
//                NSString *content = [record contentForUpload];
//                [self.uploadArray addObject:content];
//            }
//        }
//    });
    NSArray *uploadArray = [self.uploadArray copy];
    
    dispatch_async(logQueue(), ^{
        [self clearAllUploadArray];
        [self clearAllRecords];
    });
    return uploadArray;
}


@end
