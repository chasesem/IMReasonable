//
//  DeviceHard.m
//  IMReasonable
//
//  Created by apple on 14/12/25.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "DeviceHard.h"
#import "sys/utsname.h"

@implementation DeviceHard


+(NSString*)deviceString
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone1G";
    
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone3G";
    
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone3GS";
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone4";

    
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone4s";
    
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone5";
    
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone5c";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone5c";
    
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone5s";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone5s";
    
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone6Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone6";
    
  
    
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    return @"iPhone";
}


@end
