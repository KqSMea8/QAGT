//
//  GTViewLifeCycleRecorder.m
//  MomoChat
//
//  Created by ChenZhen on 2018/11/29.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "GTViewLifeCycleRecorder.h"
#import "GTViewLifeCycleRecord.h"
#import "GTLogQueue.h"
#import "GTUploadRecordId.h"

@interface GTViewLifeCycleRecorder ()
@property (nonatomic, strong) NSMutableArray<GTViewLifeCycleRecord *> *recordsArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *uploadArray;
@end

@implementation GTViewLifeCycleRecorder
- (instancetype)init {
    self = [super init];
    if (self) {
        _recordsArray = [NSMutableArray array];
        _uploadArray = [NSMutableArray array];
    }
    return self;
}

- (void)recordBusiness:(NSString *)business
      businessHashCode:(NSString *)hashCode
    viewStateBeginTime:(NSDate *)beginTime
      viewStateEndTime:(NSDate *)endTime
         viewLifeState:(NSString *)state {
    dispatch_async(logQueue(), ^{
        GTViewLifeCycleRecord *record = [[GTViewLifeCycleRecord alloc] init];
        record.business = business;
        record.viewHashCode = hashCode;
        record.viewAppearTime = beginTime;
        record.viewDisappearTime = endTime;
        record.recordID = [GTUploadRecordId sharedManager].uploadRecordId;
        record.recordTime = [[NSDate date] timeIntervalSince1970];
        record.viewLifeState = state;
        //FIXME:考虑是否还需要此步鄹
        [self.recordsArray addObject:record];
        
        // 写入MMFile
        NSString *content = [record viewLifeCycleInfoForUpload];
        NSLog(@"viewLifeInfo:%@", content);
        if ([self.viewLifeCycleDelegate respondsToSelector:@selector(viewLifeCycleLogHead:body:)]) {
            [self.viewLifeCycleDelegate viewLifeCycleLogHead:ProfileHead body:content];
        }
    });
}

- (NSArray<NSString *> *)arrayForUpload {
    NSArray<GTViewLifeCycleRecord *> *recordsArray = [self.recordsArray copy];
    
    for (GTViewLifeCycleRecord *record in recordsArray) {
        @autoreleasepool {
//            NSString *content = [record viewLifeCycleContentForUpload];
            NSString *content = [record viewLifeCycleInfoForUpload];
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

- (void)clear {
    dispatch_async(logQueue(), ^{
        [self clearAllUploadArray];
        [self clearAllRecords];
    });
}
@end
