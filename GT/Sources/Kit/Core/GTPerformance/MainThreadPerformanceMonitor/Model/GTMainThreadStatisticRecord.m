//
//  GTMainThreadStatisticRecord.m
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/24.
//  Copyright © 2018 MoMo. All rights reserved.
//

#import "GTMainThreadStatisticRecord.h"

@implementation GTMainThreadStatisticRecord

- (nonnull NSString *)contentForUpload {
    NSMutableString *content = [NSMutableString string];
    NSString *recordId = [@(self.recordID) stringValue];
    NSString *recordTimeStamp = [NSString stringWithFormat:@"%lu", (NSUInteger)(self.recordTime * 1000)];
    NSString *stackCollectMark = @"stackCollect";
    NSString *separator = @"^";
    
    [content appendString:recordId];
    [content appendString:separator];
    [content appendString:recordTimeStamp];
    [content appendString:separator];
    [content appendString:stackCollectMark];
    [content appendString:separator];
    [content appendString:[self convertStackInfo:_stackInfo]];
    [content appendString:separator];
    [content appendString:[NSString stringWithFormat:@"%lu", (NSUInteger)([_blockStartTime timeIntervalSince1970] * 1000)]];
    [content appendString:separator];
    [content appendString:[NSString stringWithFormat:@"%lu", (NSUInteger)([_blockEndTime timeIntervalSince1970] * 1000)]];

    return content;
}

- (NSString *)convertStackInfo:(NSString *)stackInfo {
    if (!stackInfo) {
        return @"";
    }
    
    NSArray<NSString *> *parts = [stackInfo componentsSeparatedByString:@"\n"];
    if (parts.count) {
        NSMutableString *trashInfo = [parts.firstObject mutableCopy];
        [trashInfo appendString:@"\n"];
        
        stackInfo = [stackInfo stringByReplacingOccurrencesOfString:[trashInfo copy] withString:@""];
    }
    
    
    NSString *content;
    content = [stackInfo stringByReplacingOccurrencesOfString:@"\n" withString:@"&&rn&&"];
    if ([content containsString:@"&&rn&&&&rn&&"]) {
        content = [content stringByReplacingOccurrencesOfString:@"&&rn&&&&rn&&" withString:@""];
    }
    return content ?: @"";
}

@end
