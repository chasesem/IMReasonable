//
//  XMPPRoomDao.h
//  IMReasonable
//
//  Created by apple on 15/3/18.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPRoom.h"
#import "IMRoomDelegate.h"

@interface XMPPRoomDao : NSObject<XMPPRoomDelegate>

- (void)createRoom:(NSString *)roomname;
- (void)ChangeSubject:(NSString*)roomjidstr subject:(NSString *)subject;
- (void)InviteUser:(NSString *)jidstr subject:(NSString *)subject;
- (NSMutableDictionary*)parserConfigElement:(NSXMLElement *)configForm;
- (NSXMLElement*)DictToBSXMLElement:(NSMutableDictionary*)dict;
-(NSMutableDictionary*)getRoomConfig:(NSMutableDictionary*)con user:(NSMutableArray *) arr subject:(NSString *)subject;

+ (XMPPRoomDao*)sharedXMPPManager;
@property (nonatomic,strong) id<RoomHelerpDelegate> roomHelerpDelegate;

@property (nonatomic, strong, readonly) XMPPRoom * xmppRoom;;
@end
