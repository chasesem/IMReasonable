//
//  IMChatListModle.h
//  IMReasonable
//
//  Created by apple on 15/3/11.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMessage.h"

@interface IMChatListModle : NSObject

//用户数据
@property (nonatomic, copy) NSString * jidstr;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *localname;
@property (nonatomic, copy) NSString *phonenumber;
@property (nonatomic, copy) NSString *addrefID;
@property (nonatomic, copy) NSString *faceurl;
@property (nonatomic, copy) NSString *photo;
@property (nonatomic, copy) NSString *group;//发件人（对群有用，个人则为空）
@property (nonatomic, copy) NSString *ihash;//头像是否更新的hash值
@property (nonatomic, copy) NSString *state;//暂时没用
@property (nonatomic, copy) NSString *isactive;//是否认证
@property (nonatomic, copy) NSString *isimrea;//是否认证(在群的时候表示是否被移除群或自己退出群即是否是合法用户)
@property (nonatomic, copy) NSString *isloc;//本地的手机号码是否为talkking用户(1:不是,0:是)
@property (nonatomic, copy) NSString *device;
@property (nonatomic, copy) NSString *update;//最后一次登入时间
@property (nonatomic, copy) NSString *unreadcount;
@property (nonatomic, copy) NSString *isRoom;//是否是群聊
@property (nonatomic, copy) NSString *isCreatMe;
@property (nonatomic, copy) NSString *tempText;//缓存的在输入框中未发送的文本消息
@property (nonatomic, copy) NSString *phoneown;//jidstr的前半段（即他自己的电话号码）
@property (nonatomic, copy) NSString *isNeedTip;//针对群，收到消息是否响铃
@property (nonatomic, copy) NSString *accouttype;//特殊账号（可以用来收邮件）


//后面添加的两个属性
@property (nonatomic, strong) IMMessage *messagebody;//最后一条消息
@property (nonatomic, copy) NSString *messageCount;
@end
