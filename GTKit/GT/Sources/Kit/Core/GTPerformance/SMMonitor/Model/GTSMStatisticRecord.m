//
//  GTSMStatisticRecord.m
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/29.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "GTSMStatisticRecord.h"

@implementation GTSMStatisticRecord
- (nonnull NSString *)contentForUpload {
    NSMutableString *content = [NSMutableString string];
    NSString *recordId = [@(self.recordID) stringValue];
    NSString *recordTimeStamp = [NSString stringWithFormat:@"%lu", (NSUInteger)(self.recordTime * 1000)];
    NSString *frameCollectMark = @"frameCollect";
    NSString *separator = @"^";
    
    [content appendString:recordId];
    [content appendString:separator];
    [content appendString:recordTimeStamp];
    [content appendString:separator];
    [content appendString:frameCollectMark];
    [content appendString:separator];
    [content appendString:_vSyncTime];
    
    return content;
}
@end
