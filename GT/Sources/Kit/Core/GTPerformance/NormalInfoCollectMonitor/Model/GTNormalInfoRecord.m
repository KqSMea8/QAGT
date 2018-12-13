//
//  GTNormalInfoRecord.m
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/12/5.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "GTNormalInfoRecord.h"

@implementation GTNormalInfoRecord
- (nonnull NSString *)contentForUpload {
    NSMutableString *content = [NSMutableString string];
    NSString *recordId = [@(self.recordID) stringValue];
    NSString *recordTimeStamp = [NSString stringWithFormat:@"%lu", (NSUInteger)(self.recordTime * 1000)];
    NSString *normalCollectMark = @"normalCollect";
    NSString *separator = @"^";
    
    [content appendString:recordId];
    [content appendString:separator];
    [content appendString:recordTimeStamp];
    [content appendString:separator];
    [content appendString:normalCollectMark];
    [content appendString:separator];
    [content appendString:recordTimeStamp];
    [content appendString:separator];
    [content appendString:@"0"];    // iOS这个位置写0
    [content appendString:separator];
    [content appendString:_cpuUsage];
    [content appendString:separator];
    [content appendString:_threadInfo];
    [content appendString:separator];
    [content appendString:_footPrintMemory];
    [content appendString:separator];
    [content appendString:_transferStream];
    [content appendString:separator];
    [content appendString:_receiveStream];
    [content appendString:separator];
    [content appendString:@"0"];    // GT线程信息，暂时置为0
    
    return content;
}
@end
