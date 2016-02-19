//
//  SelectDelegate.h
//  IMReasonable
//
//  Created by apple on 15/3/20.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//
#import <UIKit/UIKit.h>
#ifndef IMReasonable_SelectDelegate_h
#define IMReasonable_SelectDelegate_h

@protocol SelectUserDelegate <NSObject>

@optional   //加上该字段意味着不实现代理方法也不会报警告
//当用户状态改变的时候调用
-(void)SelectUserData:(NSMutableArray*)presence withsubject:(NSString *)subject;
@end
#endif
