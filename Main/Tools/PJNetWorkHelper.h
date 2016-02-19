//
//  PJNetWorkHelper.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/21.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJNetWorkHelper : NSObject
//提示没有网络
+(void)NoNetWork;
//判断网络是否可用
+(BOOL)isNetWorkAvailable;
@end
