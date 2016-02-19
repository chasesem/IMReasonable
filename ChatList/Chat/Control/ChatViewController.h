//
//  ChatViewControl.h
//  IMReasonable
//
//  Created by apple on 15/6/12.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

@class MessageModel;

#import <UIKit/UIKit.h>
#import "IMChatListModle.h"
#import "WeChatKeyBoard.h"
#import "WeChatTableViewCell.h"
#import "AppDelegate.h"

@protocol BackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface ChatViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,WeChatKeyBoardDelegate,WeChatTableViewCellDelegate,ChatHelerpDelegate,FriendreceivemsgDelegate,AuthloginDelegate,BackButtonHandlerProtocol,UINavigationBarDelegate>

//转发的消息模型
@property(nonatomic,strong)MessageModel *forwardMessageModel;

@property (nonatomic,strong) IMChatListModle * from;
@property (nonatomic,copy) NSString * myjibstr;

@property (nonatomic,copy) NSString * forwardmssage;//转发的信息内容
@property  BOOL  isforward;//是否转发

@property  BOOL  isNeedCustom;

@end
