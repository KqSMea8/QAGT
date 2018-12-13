//
//  GTNetTrafficModel.h
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/12/3.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    GTNotReachable = 0,
    GTReachableViaWiFi,
    GTReachableViaWWAN
} NetStatus;

@interface GTNetData : NSObject
{
    int64_t    _wifiSent;
    int64_t    _wifiRev;
    int64_t    _WWANSent;
    int64_t    _WWANRev;
}

@property (nonatomic, assign) int64_t wifiSent;
@property (nonatomic, assign) int64_t wifiRev;
@property (nonatomic, assign) int64_t WWANSent;
@property (nonatomic, assign) int64_t WWANRev;

@end


@interface GTNetTrafficModel : NSObject
{
    SCNetworkReachabilityRef _reachability;
    SCNetworkReachabilityContext _context;
    NetStatus          _networkStatus;
    
    NSTimeInterval      _date;
    
    BOOL         _prevValid;
    int64_t      _prevWiFiSent;
    int64_t      _prevWiFiReceived;
    int64_t      _prevWWANSent;
    int64_t      _prevWWANReceived;
    
    int64_t      _WiFiSent;
    int64_t      _WiFiReceived;
    int64_t      _WWANSent;
    int64_t      _WWANReceived;
    
    char         _netInfo[128];   //记录上一次的数据，对于NET历史数据，只保存变化的，如果没有变化，历史数据不保存
    BOOL         _newRecord; //标识是否为新记录，判断新记录的标准为当前netInfo是否和之前的netInfo有变化
}


// 总的上行流量
- (NSString *)transferStream;
//总的下行流量
- (NSString *)receiveStream;

//@property (nonatomic) NetStatus netStatus;
//@property (nonatomic, readonly) int64_t prevWiFiSent;
//@property (nonatomic, readonly) int64_t prevWiFiReceived;
//@property (nonatomic, readonly) int64_t prevWWANSent;
//@property (nonatomic, readonly) int64_t prevWWANReceived;
//
//@property (nonatomic, readonly) int64_t WiFiSent;
//@property (nonatomic, readonly) int64_t WiFiReceived;
//@property (nonatomic, readonly) int64_t WWANSent;
//@property (nonatomic, readonly) int64_t WWANReceived;



@end

NS_ASSUME_NONNULL_END
