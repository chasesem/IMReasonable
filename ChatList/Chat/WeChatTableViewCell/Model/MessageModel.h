//
//  MessageModel.h
//  KeyBoard
//
//  Created by apple on 15/6/1.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeEmail    =5,//邮箱
    MessageTypeText     = 0 , // 文字
    MessageTypePicture  = 1 , // 图片
    MessageTypeVoice    = 2 ,  // 语音
    MessageTypeTips     =3,   //提示
    MessageTypeTime     =4    //时间
};


@interface MessageModel : NSObject
@property (nonatomic, copy)NSString *ID;//保存到数据库的id
@property (nonatomic, copy) NSString *faceurl;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *voicepath;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString  *isNeedSend;
@property (nonatomic, copy) NSString  *isReceived;//是否接收到
@property (nonatomic, assign) MessageType type;
@property (nonatomic, assign) BOOL isFromMe;



@end
