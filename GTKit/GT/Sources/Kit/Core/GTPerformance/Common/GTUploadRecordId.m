//
//  GTUploadRecordId.m
//  MomoChat
//
//  Created by ChenZhen on 2018/11/29.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "GTUploadRecordId.h"

@implementation GTUploadRecordId

#pragma mark - Singleton
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static GTUploadRecordId *sharedSingleton = nil;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[super allocWithZone:NULL] init];
        [sharedSingleton commonInit];
    });
    return sharedSingleton;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedManager];
}

- (instancetype)copy {
    return self;
}

- (instancetype)mutableCopy {
    return self;
}

- (void)commonInit {
    // 从2开始。0是AppInfo，1是DeviceInfo
    _uploadRecordId = 2;
}

- (NSUInteger)uploadRecordId {
    return _uploadRecordId++;
}

@end
