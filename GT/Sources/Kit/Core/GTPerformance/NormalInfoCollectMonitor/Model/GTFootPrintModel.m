//
//  GTFootPrintModel.m
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/12/3.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "GTFootPrintModel.h"
#import "BSBacktraceLogger.h"

#include <mach/mach.h>
#include <malloc/malloc.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/mman.h>

#define M_K_B_1024 1024

@interface GTFootPrintModel ()
{
    NSUInteger          _appMemory;
}
@end

@implementation GTFootPrintModel

- (NSString *)residentMomory {
    _appMemory = [self updateMemoryFootPrint];
    NSUInteger mem = _appMemory;
    return [@(mem) stringValue];
}

// 老接口，Apple已经不建议使用
- (NSUInteger)updateMemoryResidentSizeOld {
    struct task_basic_info t_info;
    mach_msg_type_number_t t_info_count = TASK_BASIC_INFO_COUNT;
    int r = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&t_info, &t_info_count);
    if (r == KERN_SUCCESS)
    {
        return t_info.resident_size / M_K_B_1024;
    }
    else
    {
        return -1;
    }
}

// Apple 建议的新的接口
// 获取常驻内存（DirtyMemory + CompressedMemory + CleanMemory）
// 改返回值比Xcode中显示的内存大，因为Xcode统计的内存不包括CleanMemory
- (NSUInteger)updateMemoryResidentSize {
    struct mach_task_basic_info t_info;
    mach_msg_type_number_t t_info_count = MACH_TASK_BASIC_INFO_COUNT;
    int r = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&t_info, &t_info_count);
    if (r == KERN_SUCCESS) {
        return t_info.resident_size / M_K_B_1024;
    } else {
        return -1;
    }
}

// 获取memoryFootPrint（DirtyMemory + CompressedMemory）
// 结果和Xcode一致
- (NSUInteger)updateMemoryFootPrint {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t result = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if (result != KERN_SUCCESS) {
        return 0;
    }
    return (NSUInteger)((vmInfo.phys_footprint) / M_K_B_1024);
}

@end
