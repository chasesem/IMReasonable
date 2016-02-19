//
//  XMPPDao.h
//  IMReasonable
//
//  Created by apple on 15/3/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "IMDelegate.h"
#import "IMReasonableDao.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Reachability.h"

@interface XMPPDao : NSObject<XMPPStreamDelegate,XMPPReconnectDelegate>
{
 
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    BOOL isReg;
    BOOL isXmppConnected;
    
     NSString *password;

}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;


@property  BOOL isConnectInternet;
@property  BOOL isLogin;
@property  BOOL isReg;


@property (nonatomic,weak) id<ChatHelerpDelegate> chatHelerpDelegate;
@property (nonatomic,weak) id<AuthloginDelegate> authloginDelegate;
@property (nonatomic,weak) id<InternetConnectDelegate> internetConnectDelegate;
@property (nonatomic,weak) id<FriendreceivemsgDelegate> friendreceivemsgDelegate;
@property (nonatomic,weak) id<RoomDelegate> roomDelegate;


@property (nonatomic, strong) Reachability * reachability;




+ (XMPPDao*)sharedXMPPManager;
+(void)GetAllRoom;
- (BOOL)connect;
- (void)disconnect;
- (void)goOnline;
- (void)goOffline;
- (void)queryRoster;
- (void) queryOneRoster:(NSString *) jibstr;
- (void)XMPPAddFriendSubscribe:(NSString *)name;
- (void)XMPPAddFriendSubscribe2:(NSString *)jidstr;
- (void) SetUserPhoto:(NSString *)jidstr photo:(NSString *) pho;
- (void)loginChatRoom:(NSString *)roomjidstr;
-(void)SetOneLeave:(NSString *)Roomjidstr leaveuser:(NSString *)userjidstr iqid:(NSString *)iqid;
-(void)doMessage:(XMPPMessage *)message;
- (void)setapplicationIconBadgeNumber;
- (void)DestroyRoom:(NSString *)roomjidstr;
-(void)GetRoomUserList:(NSString *)roomjidstr;
- (void)SetMyPushName:(NSString *)Name;
- (void)addUserToRoom:(NSString *)roomjidstr userjidstr:(NSString *)jidstr roomname:(NSString *)inviteMessageStr;
//发消息
- (void) sendChatMessage:(NSString *) fromjidstr type:(NSString *) type body:(NSString *)msg voicelenth:(NSString *)vl msgID:(NSString *) msgID;
- (void) sendChatRoomMessage:(NSString *) fromjidstr type:(NSString *) type body:(NSString *)msg voicelenth:(NSString *)vl msgID:(NSString *) msgID;
- (void)photoChange;
- (void)checkUser:(NSMutableArray *)userarr;

- (void)getAllMyRoom;
-(void)GetRoomInfo:(NSString*)roomjidstr;
@end
