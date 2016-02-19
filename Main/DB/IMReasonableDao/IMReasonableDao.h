//
//  IMReasonableDao.h
//  IMReasonable
//
//  Created by apple on 15/3/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDBDao.h"
#import "FMDB.h"
#import "IMChatListModle.h"
#import "IMMessage.h"
#import "IMUser.h"
#import "IMDelegate.h"



@interface IMReasonableDao : NSObject
+(void)updateEmailID:(NSString *)msgID WithJID:(NSString *)jid;
//删除邮件
+(BOOL)removeEmail:(NSString *)msgID;
+(int)getEmailCount;
//获取邮件
+(NSMutableArray *)getEmailArray:(NSString *)jid WithPagerNumber:(long)pagerNumber  AndCount:(long)count;
//清除聊天记录
+(BOOL)clearAllChatMessage:(NSString *)myjidstr;

+(NSString *)GetUserLocalNameByjidstr:(NSString *)jidstr;
+(void)initIMReasonableTable;
+  (BOOL) saveMessage:(NSString *) from to:(NSString *) to body:(NSString *) body type:(NSString *) type date:(NSString *)date
           voicelenth:(NSString *)voicelenth msgID:(NSString *) msgID;
+  (void) saveUser:(NSString *) jidstr nick:(NSString *) nick group:(NSString *) group isimrea:(NSString *) isimrea;
+  (void) saveUser:(NSString *) jidstr msgID:(NSString *)msgID;
+ (void) updateMsgAccpect:(NSString *)msgID;
//+  (void) updateUseractive:(NSString *)jibstr msgID:(NSString *) msgID;
//+  (void) updateUseractive:(NSString *)jibstr tojidstr:(NSString *)tojidstr msgID:(NSString *) msgID;
+  (void) updateUseractive:(NSString *)jibstr tojidstr:(NSString *)tojidstr msgID:(NSString *) msgID accounttype:(NSString *)type localname:(NSString *)name;
+  (void) updateUserfaceurl:(NSString *)jibstr faceurl:(NSString *) faceurl;
+ (void) setUserDevice:(NSString *)jibstr device:(NSString *)device state:(NSString *) state isneedtime:(BOOL) flag;
+ (BOOL) isNeedupdateUserPhoto:(NSString *)jidstr photo:(NSString *) cpho hash:(NSString *) chash;
+ (int)getUnreadMessageCount;
+  (void) saveUserLocalNick:(NSString *) jibstr image:(NSString *) nickname addid:(NSString *)addid;
+(NSMutableArray*)getChatlistModle;
+(NSMutableArray*)getContactsListModle;
+(NSMutableArray*)getAllUserbyUpdateDesc;
+  (void) saveUserLocalNick:(NSString *) jibstr  isImrea:(NSString *) isrea;
+  (void) saveUserLocalNick:(NSString *) phone image:(NSString *) nickname addid:(NSString *)addid  isImrea:(NSString *) isrea phonetitle:(NSString *)title;
+(NSMutableArray*)getMessageByFormAndToJidstr:(NSString *)fromjidstr Tojidstr:(NSString*)tojidstr withRowCount:(NSString *)rowcount;
+(NSMutableArray*)getMessageByFormAndToJidstr2:(NSString *)fromjidstr Tojidstr:(NSString*)tojidstr withRowCount:(NSString *)rowcount;
+ (void) saveMessage2:(NSString *) from to:(NSString *) to body:(NSString *) body type:(NSString *) type date:(NSString *)date voicelenth:(NSString *)lenth msgID:(NSString *) msgID;
+ (void) setMessageRead:(NSString*)formjidstr needactive:(BOOL)flag;
+  (void) updatesendstate:(NSString*) msgID  isNeedSend:(NSString *)state;
+(NSMutableArray*)getAllactiveUser;
+(NSMutableArray*)getAllChatRoom;
+(BOOL)creatChatRoom:(NSString *)roomjidstr nick:(NSString *)nick subject:(NSString *)subject faceurl:(NSString *) facurl isMeCreat:(NSString*)isCreatMe;
+(BOOL)addRoomUser:(NSString *)roomjidstr userjidstr:(NSString *)userjidstr role:(NSString *)role;

+ (BOOL)SaveGroupMessage:(NSString *)msgID  fromjidstr:(NSString *)formjidstr tojidstr:(NSString *)tojidstr body:(NSString *)body type:(NSString *)type date:(NSString *)date groupfrom:(NSString *)groupfrom;

+ (BOOL)SaveGroupMessage2:(NSString *)msgID  fromjidstr:(NSString *)formjidstr tojidstr:(NSString *)tojidstr body:(NSString *)body type:(NSString *)type date:(NSString *)date groupfrom:(NSString *)groupfrom voicelenth:(NSString *)voicelenth;

+(NSMutableArray*)getAllLocalUser;
+  (void) updateChatRoom:(NSString *)jibstr msgID:(NSString *) msgID;
+(NSMutableArray*)getChatRoomMessage:(NSString *)roomjidstr rowCount:(NSString *)rowcount;
+(NSMutableArray*)getChatRoomMessage2:(NSString *)roomjidstr rowCount:(NSString *)rowcount;
+(NSMutableArray *)getAllUser;
+(void)updateUserIsLocal:(NSString *) indata;
+(void)updateUserIsLocalWithJidstr:(NSString *) jidstr;
+(void)updateRoomFaceurl:(NSString *) faceurl roomjidstr:(NSString *)jidstr;
+(NSMutableArray *)getOneRoomUser:(NSString *)roomjidstr;
+(BOOL)deleteRoomUser:(NSString *)roomjidstr userjidstr:(NSString *)userjidstr;
+(BOOL)deleteUser:(NSString *)jidstr;
+(void) setNotinRoom:(NSString*) jidstr;
+(void) setRoomisMy:(NSString*) jidstr;
+(void)clearRoomUser;
+(void)clearRoomUser:(NSString *)roomjidstr;
+(void) setTempText:(NSString*) jidstr text:(NSString *)text;
+  (BOOL) deleteOneMessageWithID:(NSString *)msgID;
+  (BOOL) markDeleteOneMessageWithID:(NSString *)msgID;
+(void)updateRoomLocalname:(NSString *)jidstr nickname:(NSString *)nick;

+(NSInteger)getRoomUserCount:(NSString *)jidstr;
+(BOOL)updateNotShow:(NSString*)jidstr;
+(BOOL)setUserNeedTips:(NSString*)jidstr vaule:(NSString*)vaule;
@end
