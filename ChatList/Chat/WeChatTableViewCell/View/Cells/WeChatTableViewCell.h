//
//  WeChatTableViewCell.h
//  KeyBoard
//
//  Created by apple on 15/6/1.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageContent.h"
#import "MessageModel.h"
#import "PictureContent.h"

@protocol WeChatTableViewCellDelegate;

@interface WeChatTableViewCell : UITableViewCell<MessageContentDelegate,PictureContentDelegate>


@property (nonatomic,retain) MessageModel * messagemode;
@property (nonatomic, weak) id<WeChatTableViewCellDelegate> delegate;

+(CGFloat)getCellHeight:(MessageModel *)messagemode isNeedName:(BOOL)isName;
- (void)setMessagemode:(MessageModel *)messagemode isNeedName:(BOOL)isName;

@end


//消息内容的协议
@protocol WeChatTableViewCellDelegate <NSObject>

@optional   //加上该字段意味着不实现代理方法也不会报警告
-(void)touchMessageContent:(NSString *)content withType:(TouchContentType)type;
-(void)touchPictureContent:(MessageModel*)mod tableviewcell:(UITableViewCell*)cell ImageView:(UIImageView *)imageView;
-(void)reSendMessage:(MessageModel*)message;
-(void)acDeteleMessage:(MessageModel*)message;
-(void)acForwardMessage:(MessageModel*)message;

@end