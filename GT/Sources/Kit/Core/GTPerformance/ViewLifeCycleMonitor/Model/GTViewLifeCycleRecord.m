//
//  GTViewLifeCycleRecord.m
//  MomoChat
//
//  Created by ChenZhen on 2018/11/29.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "GTViewLifeCycleRecord.h"
#import "GTUploadRecordId.h"

@implementation GTViewLifeCycleRecord

- (nonnull NSString *)viewLifeCycleInfoForUpload {
    NSMutableString *content = [NSMutableString string];
    NSString *recordId = [@(self.recordID) stringValue];
    NSString *recordTimeStamp = [NSString stringWithFormat:@"%lu", (NSUInteger)(self.recordTime * 1000)];
    NSString *separator = @"^";
    
    [content appendString:recordId];
    [content appendString:separator];
    [content appendString:recordTimeStamp];
    [content appendString:separator];
    [content appendString:_viewLifeState];
    [content appendString:separator];
    [content appendString:_business];
    [content appendString:separator];
    [content appendString:_viewHashCode];
    [content appendString:separator];
    [content appendString:[NSString stringWithFormat:@"%lu", (NSUInteger)([_viewAppearTime timeIntervalSince1970] * 1000)]];
    [content appendString:separator];
    [content appendString:[NSString stringWithFormat:@"%lu", (NSUInteger)([_viewDisappearTime timeIntervalSince1970] * 1000)]];
    
    return content;
}




@end
