//
//  IMUser.h
//  IMReasonable
//
//  Created by apple on 15/3/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMUser : NSObject
//User 的模型
@property (nonatomic, strong) NSString * jidstr;
@property (nonatomic, strong) NSString *nick;
@property (nonatomic, strong) NSString *localname;
@property (nonatomic, strong) NSString *addrefID;
@property (nonatomic, strong) NSString *faceurl;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSString *ihash;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *isactive;
@property (nonatomic, strong) NSString *isimrea;
@property (nonatomic, strong) NSString *isloc;
@property (nonatomic, strong) NSString *device;
@property (nonatomic, strong) NSString *update;
@property (nonatomic, strong) NSString *unreadcount;
@end
