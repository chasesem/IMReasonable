//
//  DesHelper.h
//  IMReasonable
//
//  Created by apple on 15/1/13.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DesHelper : NSObject
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key;
+ (NSString *)textFromBase64String:(NSString *)base64 withKey:(NSString*)key;
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
@end
