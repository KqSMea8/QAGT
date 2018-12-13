//
//  GTCPUUsage.m
//  testDis
//
//  Created by ChenZhen on 2018/12/3.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "GTCPUUsage.h"
#include <mach/mach.h>
#include <malloc/malloc.h>

#import <sys/sysctl.h>
#import <sys/types.h>
#import <sys/param.h>
#import <sys/mount.h>
#import <mach/processor_info.h>
#import <mach/mach_host.h>
#import "BSBacktraceLogger.h"

@interface GTCPUUsage ()
{
    float cpu_usage;
}

@end

@implementation GTCPUUsage 

- (NSString *)cpuUsage {
    
    return [NSString stringWithFormat:@"%.0f", [self getCpuUsage]];
}


- (float)getCpuUsage
{
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
        return -1;
    }
    // 初始化
    cpu_usage = 0;
    
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
            return -1;
        }
        
        // 如果为非空闲线程
        if (!(basic_info_th->flags & TH_FLAGS_IDLE))
        {
            // 计算所有线程cpu使用率之和
            cpu_usage += basic_info_th->cpu_usage;
            
        }
    }
    
    cpu_usage = cpu_usage / (float)TH_USAGE_SCALE * 100.0;
    
    vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    
    return cpu_usage;
}
@end
