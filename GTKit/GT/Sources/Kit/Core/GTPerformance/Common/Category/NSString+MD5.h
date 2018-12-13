//
//  NSString+MD5.h
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/11/25.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MD5)
+ (NSString *)md5To32bit:(NSString *)str;

- (NSString *)md5String;
@end

NS_ASSUME_NONNULL_END
