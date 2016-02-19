//
//  AnimationHelper.h
//  IMReasonable
//
//  Created by apple on 14/11/14.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimationHelper : NSObject
+(void)show:(NSString *)msg InView:(UIView *)view;
+ (void)showHUD:(NSString *)msg;
+ (void)removeHUD;
@end
