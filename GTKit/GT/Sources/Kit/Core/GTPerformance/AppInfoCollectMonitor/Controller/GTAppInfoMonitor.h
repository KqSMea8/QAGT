//
//  GTAppInfoMonitor.h
//  MomoChat
//
//  Created by ChenZhen on 2018/12/6.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTRecordLogDelegate.h"

#define GTAppInfoSharedManager [GTAppInfoMonitor sharedInstance]

NS_ASSUME_NONNULL_BEGIN

@interface GTAppInfoMonitor : NSObject

+ (instancetype)sharedInstance;

- (void)startMonitor;
- (void)stopMonitor;

@property (nonatomic, weak) id<GTRecordLogDelegate> appInfoDelegate;
@property (nonatomic, weak) id<GTRecordLogDelegate> deviceInfoDelegate;

@end

NS_ASSUME_NONNULL_END
