//
//  Person.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/20.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
//手机号码集合
@property(nonatomic,copy)NSArray *phoneArray;
//邮箱集合
@property(nonatomic,copy)NSArray *emailArray;
//用户的名字
@property(nonatomic,copy)NSString *name;
@end
