//
//  MessageContent.h
//  KeyBoard
//
//  Created by apple on 15/6/1.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"
#import "TQRichTextView.h"

typedef NS_ENUM(NSInteger, TouchContentType) {
    TouchContentTypeURL     = 0 , //点击链接
};
@protocol MessageContentDelegate;


@interface MessageContent : UIView<TQRichTextViewDelegate>
@property (nonatomic,retain) UIImageView * backgroundImage;
@property (nonatomic,retain) MessageModel * messagemode;

@property (nonatomic,weak) id<MessageContentDelegate> delegate;
- (void)setMessagemode:(MessageModel *)messagemode isNeedName:(BOOL)isName;


@end

//消息内容的协议
@protocol MessageContentDelegate <NSObject>

@optional   //加上该字段意味着不实现代理方法也不会报警告
-(void)touchMessageContent:(NSString *)content withType:(TouchContentType)type;


@end