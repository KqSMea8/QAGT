//
//  GTLogQueue.h
//  MomoChat
//
//  Created by ChenZhen on 2018/11/29.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#ifndef GTLogQueue_h
#define GTLogQueue_h

/*!
 *  @brief 记录Log信息队列
 */
static inline dispatch_queue_t logQueue() {
    static dispatch_queue_t logQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, DISPATCH_QUEUE_PRIORITY_LOW , 0);
        logQueue = dispatch_queue_create("com.momo.performanceMonitor.logQueue", attr);
    });
    return logQueue;
}

#endif /* GTLogQueue_h */
