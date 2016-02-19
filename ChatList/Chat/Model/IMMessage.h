//
//  IMMessage.h
//  IMReasonable
//
//  Created by apple on 15/3/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMMessage : NSObject
//消息的Modles
@property (nonatomic, copy)NSString *ID;
@property (nonatomic, copy)NSString *from;
@property (nonatomic, copy)NSString *to;
@property (nonatomic, copy)NSString *body;
@property (nonatomic, copy)NSString *type;
@property (nonatomic, copy)NSString *date;
@property (nonatomic, copy)NSString *groupfrom;//群的时候是谁发的
@property (nonatomic, copy)NSString *isneedsend;
@property (nonatomic, copy)NSString *isaccpet;

//人物显示属性
@property (nonatomic, copy)NSString *jidstr;
@property (nonatomic, copy)NSString *localname;
@property (nonatomic, copy)NSString *faceurl;
@end
