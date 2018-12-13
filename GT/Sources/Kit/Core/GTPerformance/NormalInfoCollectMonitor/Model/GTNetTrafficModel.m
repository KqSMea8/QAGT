//
//  GTNetTrafficModel.m
//  PerformanceMonitor
//
//  Created by ChenZhen on 2018/12/3.
//  Copyright © 2018 MOMO. All rights reserved.
//

#import "GTNetTrafficModel.h"
#import <ifaddrs.h>
#import <sys/socket.h>
#import <net/if.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/mman.h>
#import <mach/mach.h>
#import <netinet/in.h>
#import <arpa/inet.h>


#define M_SIZE_128 128

#define M_K_B_1024 1024

@implementation GTNetTrafficModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        _prevValid        = false;
        _prevWiFiSent     = 0;
        _prevWiFiReceived = 0;
        _prevWWANSent     = 0;
        _prevWWANReceived = 0;
        
        _WiFiSent     = 0;
        _WiFiReceived = 0;
        _WWANSent     = 0;
        _WWANReceived = 0;
        
        _networkStatus = [self currentNetStatus];
        
        memset(_netInfo, 0, sizeof(_netInfo));
    }
    return self;
}

- (NSString *)transferStream {
    NSString *ts = [@([self totalSent]) stringValue];
    
    NSLog(@"transferStream:%@", ts);
    return ts;
}

- (NSString *)receiveStream {
    NSString *rs = [@([self totalReceive]) stringValue];
    NSLog(@"receiveStream:%@", rs);
    return rs;
}

- (int64_t)totalSent {
    [self updateNetData];
    return _WiFiSent + _WWANSent;
}

- (int64_t)totalReceive {
    [self updateNetData];
    return _WiFiReceived + _WWANReceived;
}

- (void)updateNetData
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    int64_t WiFiSent = 0;
    int64_t WiFiReceived = 0;
    int64_t WWANSent = 0;
    int64_t WWANReceived = 0;
    
    success = getifaddrs(&addrs) == 0;
    
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if (strcmp(cursor->ifa_name, "en0") == 0)
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                }
                if (strcmp(cursor->ifa_name, "pdp_ip0") == 0)
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    
    if (_prevValid) {
        _WiFiSent = WiFiSent - _prevWiFiSent;
        _WiFiReceived = WiFiReceived - _prevWiFiReceived;
        _WWANSent = WWANSent - _prevWWANSent;
        _WWANReceived = WWANReceived - _prevWWANReceived;
        
    } else {
        //记录第一次启动监控的流量
        _prevValid = YES;
        _prevWiFiSent = WiFiSent;
        _prevWiFiReceived = WiFiReceived;
        _prevWWANSent = WWANSent;
        _prevWWANReceived = WWANReceived;
    }
    
//    char info[M_SIZE_128] = {0};
//    memset(info, 0, M_SIZE_128);
//    snprintf(info, M_SIZE_128 - 1, "Wifi T:%.3fKB R:%.3fKB\rWWAN T:%.3fKB R:%.3fKB", _WiFiSent/M_K_B_1024,_WiFiReceived/M_K_B_1024,_WWANSent/M_K_B_1024,_WWANReceived/M_K_B_1024);
    
    //和之前的信息对比判断是否有变化
//    if (!strcmp(_netInfo, info)) {
//        _newRecord = NO;
//    } else {
//        _newRecord = YES;
//
//        _date = [[NSDate date] timeIntervalSince1970];
//        memset(_netInfo, 0, sizeof(_netInfo));
//        //记录本次信息，用于下次采集时判断是否有变化
//        memcpy(_netInfo, info, sizeof(info));
//    }
    
    return;
}

- (NetStatus) currentNetStatus
{
    _networkStatus = GTNotReachable;
    SCNetworkReachabilityFlags flags;
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    _reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    
    if (SCNetworkReachabilityGetFlags(_reachability, &flags))
    {
        [self updateNetworkStatusForFlags:flags];
    }
    
    if (_reachability != NULL) {
        CFRelease(_reachability);
    }
    
    return _networkStatus;
}

// 更新网络状态
- (void)updateNetworkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        _networkStatus = GTNotReachable;
        return;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        _networkStatus = GTReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            _networkStatus = GTReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        _networkStatus = GTReachableViaWWAN;
    }
    return;
}


@end
