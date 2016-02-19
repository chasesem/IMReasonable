//
//  IMDelegate.h
//  IMReasonable
//
//  Created by apple on 15/3/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//



#import "IMMessage.h"
#import "XMPPFramework.h"


#ifndef IMReasonable_IMDelegate_h
#define IMReasonable_IMDelegate_h


//添加聊天的代理，以便在其他的页面做必要的消息
@protocol ChatHelerpDelegate <NSObject>

@optional   //加上该字段意味着不实现代理方法也不会报警告
//当用户状态改变的时候调用
-(void)userStatusChange:(XMPPPresence *)presence;
//当用户收到消息的时候调用
-(void)receiveNewMessage:(IMMessage *)message isFwd:(BOOL) isfwd;
- (void) isSuccSendMessage:(IMMessage *)msg issuc:(BOOL) flag;
@end


//添加聊天的代理，以便在其他的页面做必要的消息
@protocol AuthloginDelegate <NSObject>

@optional   //加上该字段意味着不实现代理方法也不会报警告
//当flag==true的时候登陆成功，否则登陆失败
- (void) isSuccLogin:(BOOL)flag;
//当flag==true的时候表明注册成功，否则注册失败
- (void) isSuccReg:(BOOL)flag;
@end

//添加聊天的代理，添加网络代理处理网络连接情况
@protocol InternetConnectDelegate <NSObject>
@optional   //加上该字段意味着不实现代理方法也不会报警告
- (void) isConnectToInternet:(BOOL) isConnet;
@end


@protocol FriendreceivemsgDelegate <NSObject>
@optional   //加上该字段意味着不实现代理方法也不会报警告
- (void) friendreceivemsg;
@end







@protocol RoomDelegate <NSObject>
@optional   //加上该字段意味着不实现代理方法也不会报警告
- (void) deleteRoomUser:(NSInteger)state userjidstr:(NSString *)userjidstr;
- (void) deleteRoom:(NSInteger)action;
@end
#endif
