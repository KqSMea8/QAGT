//
//  GTThreadInfoModel.m
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/12/5.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "GTThreadInfoModel.h"

#import <mach/mach.h>
#include <dlfcn.h>
#include <pthread.h>
#include <sys/types.h>
#include <limits.h>
#include <string.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>

@implementation GTThreadInfoModel
+ (NSString *)allThreadInfos {
    NSMutableString *allThreadInfos = [NSMutableString string];
    BOOL firstThread = YES;
    
    kern_return_t                   kr;
    thread_array_t                  thread_list;
    mach_msg_type_number_t          thread_count;
    thread_info_data_t              thinfo;
    mach_msg_type_number_t          thread_info_count;
    thread_basic_info_t             basic_info_th;
    kern_return_t                   thread_extended_kr;
    thread_extended_info_data_t     thread_extended_info;
    mach_msg_type_number_t          thread_extended_count;
    thread_extended_info_t          extended_info_th;
    kern_return_t                   thread_identifier_kr;
    thread_identifier_info_data_t   thread_identifier_info;
    mach_msg_type_number_t          thread_identifier_count;
    thread_identifier_info_t        thread_identifier_th;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return nil;
    }
    
    for (int i = 0; i < thread_count; i++)
    {
        // 获取cpu使用率
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[i], THREAD_BASIC_INFO,(thread_info_t)thinfo, &thread_info_count);
        basic_info_th = (thread_basic_info_t)thinfo;
        
        // 获取线程name
        thread_extended_count = THREAD_EXTENDED_INFO_COUNT;
        thread_extended_kr = thread_info(thread_list[i], THREAD_EXTENDED_INFO,(thread_info_t) &thread_extended_info, &thread_extended_count);
        extended_info_th = (thread_extended_info_t)&thread_extended_info;
        
        // 获取线程id
        thread_identifier_count = THREAD_IDENTIFIER_INFO_COUNT;
        thread_identifier_kr = thread_info (thread_list[i], THREAD_IDENTIFIER_INFO,
                                            (thread_info_t) &thread_identifier_info, &thread_identifier_count);
        thread_identifier_th = (thread_identifier_info_t)&thread_identifier_info;
        
        if (kr != KERN_SUCCESS && thread_extended_kr != KERN_SUCCESS && thread_identifier_kr != KERN_SUCCESS) {
            continue;
        }
        
        // 如果为非空闲线程
        if (!(basic_info_th->flags & TH_FLAGS_IDLE))
        {
            // 获取该线程的id，name
            NSString *thread_name = [[NSString alloc] initWithFormat:@"%@_thread%@", [NSString stringWithFormat:@"%s", extended_info_th->pth_name], [[NSString alloc] initWithFormat:@"%d",i]] ;
            NSString *thread_id = [@(thread_identifier_th->thread_id) stringValue];
            NSString *thread_cpu_usage = [@(basic_info_th->cpu_usage) stringValue];
            
            [self aggregateThreadInfos:allThreadInfos
                                withId:thread_id usage:thread_cpu_usage
                                  name:thread_name
                         isFirstThread:firstThread];
            firstThread = NO;
        }
    }
    
    
    vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    
    return [allThreadInfos copy];
}

+ (void)aggregateThreadInfos:(NSMutableString *)threadInfos
                      withId:(NSString *)threadId
                       usage:(NSString *)usage
                        name:(NSString *)name
               isFirstThread:(BOOL)first {
    if (first) {
        [threadInfos appendString:[self threadInfoWithId:threadId
                                                   usage:usage
                                                    name:name]];
    } else {
        [threadInfos appendString:@","];
        [threadInfos appendString:[self threadInfoWithId:threadId
                                                   usage:usage
                                                    name:name]];
    }
    
}

+ (NSString *)threadInfoWithId:(NSString *)threadId
                         usage:(NSString *)usage
                          name:(NSString *)name {
    NSMutableString *ti = [NSMutableString string];
    [ti appendString:threadId];
    [ti appendString:@":"];
    [ti appendString:usage];
    [ti appendString:@":"];
    [ti appendString:name];
    
    return [ti copy];
}

@end
