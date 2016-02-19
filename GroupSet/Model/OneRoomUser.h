//
//  OneRoomUser.h
//  IMReasonable
//
//  Created by apple on 15/4/21.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OneRoomUser : NSObject

@property  (nonatomic,copy) NSString *roomjidstr;
@property  (nonatomic,copy) NSString *userjidstr;
@property (nonatomic,copy) NSString *role;
@property (nonatomic,copy) NSString * localname;
@property (nonatomic,copy) NSString * faceurl;

@end
