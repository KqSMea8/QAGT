//
//  GTUploadRecordId.h
//  MomoChat
//
//  Created by ChenZhen on 2018/11/29.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTUploadRecordId : NSObject

@property (nonatomic, assign) NSUInteger uploadRecordId;

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
