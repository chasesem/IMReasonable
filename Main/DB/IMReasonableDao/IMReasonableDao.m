 //
//  IMReasonableDao.m
//  IMReasonable
//
//  Created by apple on 15/3/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//



#import "IMReasonableDao.h"
#import "OneRoomUser.h"
#import "MessageModel.h"

#define GROUP_CHAT 0 //群聊
@implementation IMReasonableDao

//删除邮件
+(BOOL)removeEmail:(NSString *)msgID{
    if(![Tool isBlankString:msgID]){
        
        NSString *sql=[NSString stringWithFormat:@"delete from Message where [type]=\"email\" and [msgID]=\"%@\"",msgID];
        return [FMDBDao executeUpdate:sql];
    }else{
        
        return false;
    }
}

//删除所有的聊天记录
+(BOOL)clearAllChatMessage:(NSString *)myjidstr{
    NSString *sql=[NSString stringWithFormat:@"delete from Message where ([from]=\"%@\" or [to]=\"%@\")",myjidstr,myjidstr];
    NSLog(@"%@",sql);
    return [FMDBDao executeUpdate:sql];
}

///初始化App的用户表和历史消息表
+(void)initIMReasonableTable
{
    //[self sharedFMDBManager];
    //创建[User]
    [FMDBDao executeUpdate:@"CREATE  TABLE IF NOT EXISTS [User] ([jidstr] TEXT PRIMARY KEY  NOT NULL ,[nick] TEXT,[localname] TEXT,[addrefID] TEXT,[faceurl] TEXT DEFAULT \"default.png\",[photo] TEXT,[hash]  TEXT,[group] TEXT,[state] TEXT DEFAULT \"unavailable\" ,[isactive] TEXT DEFAULT \"0\",[isimrea] TEXT DEFAULT \"0\",[isloc] TEXT DEFAULT \"0\",[device] TEXT ,[update] DATETIME default (datetime('now', 'localtime')),[unreadcount] TEXT,[msgID]       TEXT)"];
    
    [FMDBDao executeUpdate:@"alter table User add isRoom text default '0'"]; //增加一个字段  判断是不是房间
    [FMDBDao executeUpdate:@"alter table User add phonenumber text "]; //增加一个字段       保存用户的电话号码
    [FMDBDao executeUpdate:@"alter table User add isCreatMe text default '0'"]; //增加一个字段  判断房间是不是自己创建的
    [FMDBDao executeUpdate:@"alter table User add temptext text"];             //增加一个字段   保存暂未发送的文本
    [FMDBDao executeUpdate:@"alter table User add phonetitle text"];             //增加一个字段   保存电话号码是住址还是移动
    
    [FMDBDao executeUpdate:@"alter table User add isNeedTips text default '0'"];             //增加一个字段    保存该用户是否需要提醒
    [FMDBDao executeUpdate:@"alter table User add accounttype text default '0'"];             //增加一个字段   默认值是普通账号
    
   
    
    //清除用户的状态
    [IMReasonableDao clearUserState];
    
    // 每次登陆把房间的用户清掉
    [self clearRoomUser];
    
    //创建本地消息表
    [FMDBDao executeUpdate:@"CREATE  TABLE IF NOT EXISTS [Message] ([msgID] TEXT PRIMARY KEY  NOT NULL,[from] TEXT,[to] TEXT,[body] TEXT,[type] TEXT,[groupfrom] TEXT,[date] DATETIME default (datetime('now', 'localtime')),[isneedsend] TEXT DEFAULT \"0\",[isaccpet] TEXT DEFAULT \"0\")"];
     [FMDBDao executeUpdate:@"alter table Message add voicelenth text default '0'"]; //增加一个字段
     [FMDBDao executeUpdate:@"alter table Message add markdelete text default '0'"]; //增加一个字段 钟对群消息的删除问题 折中方案
    
    
    [FMDBDao executeUpdate:@"create table IF NOT EXISTS RoomList ([roomjidstr] TEXT,[userjidstr] TEXT,[role] TEXT, primary key ([roomjidstr],[userjidstr]))"];
    //创建群主列表
    [FMDBDao executeUpdate:@"CREATE  TABLE IF NOT EXISTS [ChatRoom] ([roomjidstr] TEXT PRIMARY KEY  NOT NULL ,[nick] TEXT,[subject] TEXT,[faceurl] TEXT DEFAULT \"default.png\",[photo] TEXT,[hash]  TEXT,[update] DATETIME default (datetime('now', 'localtime')),[unreadcount] TEXT,[msgID]       TEXT)"];
    
    
}
///清除用户的状态
+(void)clearRoomUser
{
    [FMDBDao executeUpdate:@"delete from RoomList where role=\"0\""];
}

+(void)clearRoomUser:(NSString *)roomjidstr
{
    
    NSString * sql=[NSString stringWithFormat:@"delete from RoomList where role=\"0\" and roomjidstr = \"%@\"",roomjidstr];
    
    [FMDBDao executeUpdate:sql];
}
///清除用户的状态
+(void)clearUserState
{
     [FMDBDao executeUpdate:@"update [User] set [device]=\"\",[state]=\"unavailable\""];
}

+(NSString *)GetUserLocalNameByjidstr:(NSString *)jidstr
{
 
      NSString * localname=@"";
      NSString * sql=[NSString stringWithFormat:@"select * from [User]  where jidstr= \"%@\" ",jidstr];
      FMResultSet *rs=[FMDBDao executeQuery:sql];
      if ([rs next]) {
            localname=[rs stringForColumn:@"jidstr"];
       
        }
    [rs close];
    rs=nil;
    return localname;
}



#pragma 保存聊天记录
+  (BOOL) saveMessage:(NSString *) from to:(NSString *) to body:(NSString *) body type:(NSString *) type date:(NSString *)date
           voicelenth:(NSString *)voicelenth msgID:(NSString *) msgID
{
    NSLog(@"body:%@",body);
    NSString * sql=[NSString stringWithFormat:@"insert into Message([msgID],[from],[to],[body],[type],[date],[isneedsend],[isaccpet],[voicelenth]) values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",msgID,from,to,[type isEqualToString:EMAIL]?[body stringByReplacingOccurrencesOfString:@"\"" withString:@"'"]:body,type,date,@"1",@"1",voicelenth];
        BOOL result=[FMDBDao executeUpdate:sql];
    NSLog(@"sql1:%@",sql);
    NSLog(@"result:%d",result);
    sql=[NSString stringWithFormat:@"insert into [User](jidstr,[msgID],[isactive],[isloc],[unreadcount]) values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",from,msgID,@"1",@"1",@"1"];
    NSLog(@"sql2:%@",sql);
        BOOL flag= [FMDBDao executeUpdate:sql];
        if (!flag) {
             sql=[NSString stringWithFormat:@"update [User] set msgID=\"%@\" ,[isloc]=\"1\"  where jidstr= \"%@\"  ",msgID,from];
            [FMDBDao executeUpdate:sql];
        }
       return flag;
}


+  (void) saveUser:(NSString *) jidstr nick:(NSString *) nick group:(NSString *) group isimrea:(NSString *) isimrea
{
 
       NSString * sql=[NSString stringWithFormat:@"insert into User(jidstr,nick,[group],[isimrea]) values(\"%@\",\"%@\",\"%@\",\"%@\")",jidstr,nick,group,isimrea];
        
        BOOL flag=[FMDBDao executeUpdate:sql];
        
        if (!flag) {
              sql=[NSString stringWithFormat:@"update [User] set [nick]= \"%@\" ,[group]= \"%@\" ,[isimrea]=\"%@\" where jidstr=\"%@\"",nick,group,isimrea,jidstr];
            [FMDBDao executeUpdate:sql];
        }
}

+  (void) saveUser:(NSString *) jidstr msgID:(NSString *)msgID
{
  
         NSString * sql=[NSString stringWithFormat:@"update [User] set msgID=%@ where jidstr= \"%@\" ",msgID,jidstr];
        BOOL flag= [FMDBDao executeUpdate:sql];
        if (!flag) {
             sql=[NSString stringWithFormat:@"insert into [User](jidstr,[msgID]) values(\"%@\",\"%@\")",jidstr,msgID];
             [FMDBDao executeUpdate:sql];
        }
}

+ (void) updateMsgAccpect:(NSString *)msgID
{
         NSString * sql=[NSString stringWithFormat:@"update Message set isaccpet=%@ where msgID=\"%@\" ",@"1",msgID];
        [FMDBDao executeUpdate:sql];
}

//把用户更新为聊过天得用户
+  (void) updateUseractive:(NSString *)jibstr tojidstr:(NSString *)tojidstr msgID:(NSString *) msgID accounttype:(NSString *)type localname:(NSString *)name
{

         NSString * sql=[NSString stringWithFormat:@"select * from [User]  where jidstr= \"%@\" ",jibstr];
        FMResultSet *rs=[FMDBDao executeQuery:sql];
        NSString * count=@"0";
        
        if ([rs next]) {
            count=[rs stringForColumn:@"unreadcount"];
            if (count) {
                count =[NSString stringWithFormat:@"%d",[count intValue]+1];
            }
        }
        [rs close];
        rs=nil;
    
        NSString * messageID=[IMReasonableDao getUserLastMessageId:jibstr withTojidstr:tojidstr];
    
        sql=[NSString stringWithFormat:@"update User set isactive=\"1\" ,msgID=\"%@\" , unreadcount=\"%@\"  where jidstr= \"%@\" ",messageID,count,jibstr];
        BOOL flag=[FMDBDao executeUpdate:sql];
        
        if (!flag) {
             sql=[NSString stringWithFormat:@"insert into User(jidstr,[isimrea],[isactive],[msgID],[unreadcount],[accounttype]) values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",jibstr,@"1",@"1",messageID,@"1",type];
            [FMDBDao executeUpdate:sql];
        }
    
}

+ (NSString *)getUserLastMessageId:(NSString *)jidstr withTojidstr:(NSString*)tojidstr{
    NSString * sql=[NSString stringWithFormat:@"SELECT msgID FROM Message  where ( [from]=\"%@\" and  [to]=\"%@\") or ( [from]=\"%@\" and  [to]=\"%@\") order by  date desc limit 0,1 ",jidstr,tojidstr,tojidstr,jidstr];
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    NSString * msgID=@"";
    
    if ([rs next]) {
        msgID=[rs stringForColumn:@"msgID"];
    }
    [rs close];
    return msgID;
}


//把用户跟新为聊过天得用户
+  (void) updateChatRoom:(NSString *)jibstr msgID:(NSString *) msgID
{
    
    NSString * sql=[NSString stringWithFormat:@"select * from [User]  where jidstr= \"%@\" ",jibstr];
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    NSString * count=@"0";
    
    if ([rs next]) {
        count=[rs stringForColumn:@"unreadcount"];
        if (count) {
            count =[NSString stringWithFormat:@"%d",[count intValue]+1];
        }
    }
    [rs close];
    
    NSString * messageID=[IMReasonableDao getGroupLastMessageIdByRoomJidstr:jibstr];
    sql=[NSString stringWithFormat:@"update User set msgID=\"%@\" , isactive=\"1\", unreadcount=\"%@\"  where jidstr= \"%@\" ",messageID,count,jibstr];
     [FMDBDao executeUpdate:sql];
    
    
}

+ (NSString *)getGroupLastMessageIdByRoomJidstr:(NSString *)jidstr{
    NSString * sql=[NSString stringWithFormat:@"SELECT msgID FROM Message  where [from]=\"%@\" or [to]=\"%@\" order by  date desc limit 0,1 ",jidstr,jidstr];
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    NSString * msgID=@"";
    
    if ([rs next]) {
        msgID=[rs stringForColumn:@"msgID"];
    }
    [rs close];
    
    return msgID;
}

+  (void) updateUserfaceurl:(NSString *)jibstr faceurl:(NSString *) faceurl
{
    faceurl=[faceurl stringByAppendingString:@".png"];
    NSString * sql=[NSString stringWithFormat:@"update User set faceurl=\"%@\" where jidstr= \"%@\" ",faceurl,jibstr];
    [FMDBDao executeUpdate:sql];
}
//设置一个用户的设备
//update User set localnick="tim" where jibstr="15986685565@im.fmkmail.com"
+ (void) setUserDevice:(NSString *)jibstr device:(NSString *)device state:(NSString *) state isneedtime:(BOOL) flag
{
    
         NSString * sql;
        if (flag) {
            sql=[NSString stringWithFormat:@"update [User] set [device]= \"%@\" ,[update]=\"%@\",[state]=\"%@\"  where jidstr= \"%@\" ",device,[Tool GetDate:@"yyyy-MM-dd HH:mm:ss"],state,jibstr];
            [FMDBDao executeUpdate:sql];
        }else{
            sql=[NSString stringWithFormat:@"update [User] set [device]= \"\" , [state]=\"%@\" where jidstr= \"%@\" ",state,jibstr];
            [FMDBDao executeUpdate:sql];
        }
}


//把用户跟新为聊过天得用户
+ (BOOL) isNeedupdateUserPhoto:(NSString *)jidstr photo:(NSString *) cpho hash:(NSString *) chash
{
    
          NSString * sql=[NSString stringWithFormat:@"select * from [User]  where jidstr= \"%@\" ",jidstr];
   
        FMResultSet *rs=[FMDBDao executeQuery:sql];
        NSString * photo;
        NSString * hash;
       BOOL flag=false;
        
        if ([rs next]) {
            photo=[rs stringForColumn:@"photo"];
            hash=[rs stringForColumn:@"hash"];
            if (!([cpho isEqualToString:photo] && [chash isEqualToString:hash])) {
                sql=[NSString stringWithFormat:@"update User set photo=\"%@\" , hash=\"%@\"  where jidstr= \"%@\" ",cpho,chash,jidstr];
                [FMDBDao executeUpdate:sql];
                flag=true;
              }
         }
     [rs close];
    rs=nil;
    return flag;
    
}


+ (int)getUnreadMessageCount
{
    
     NSString * sql=@"select sum(unreadcount) as msgcount from User where isactive=\"1\"";
    
    __block int icount=0;
        FMResultSet *rs=[FMDBDao executeQuery:sql];
        NSString * count;
        
        if ([rs next]) {
            count=[rs stringForColumn:@"msgcount"];
            icount=[count intValue];
        }
    [rs close];
    return icount;

}

+  (void) saveUserLocalNick:(NSString *) jibstr image:(NSString *) nickname addid:(NSString *)addid
{
    NSString * jidstr=[jibstr stringByAppendingString:XMPPSERVER2];
     NSString * sql=[NSString stringWithFormat:@"update User set localname = \"%@\" , addrefID = \"%@\" WHERE jidstr = \"%@\" ",nickname,addid,jidstr];
    BOOL flag=[FMDBDao executeUpdate:sql];
    if (flag) {
            // NSString * temp=[NSString stringWithFormat:@"insert into User(jidstr,localname, addrefID) values(%@,%@,%@)",jidstr,nickname,addid];
          NSString * sql=[NSString stringWithFormat:@"insert into User(jidstr,localname, addrefID) values(\"%@\",\"%@\",\"%@\")",jidstr,nickname,addid];
         [FMDBDao executeUpdate:sql];
    }
  
    
}

//获取邮件数量
+(int)getEmailCount{
    FMResultSet *rs=[FMDBDao executeQuery:@"select count(*) as a from [Message] where type=\"email\""];
    int count=0;
    if([rs next]){
        
        count=[rs intForColumn:@"a"];
    }
    [rs close];
    rs=nil;
    return count;
}

//获取邮件(jid中包含特殊字符所以不能用于sql语句)
+(NSMutableArray *)getEmailArray:(NSString *)jid WithPagerNumber:(long)pagerNumber AndCount:(long)count{
    NSMutableArray *array=[NSMutableArray array];
    NSString *sql=[NSString stringWithFormat:@"select * from [Message] where ([to]=\"%@\" and [type]=\"email\") order by date limit %ld,%ld",jid,pagerNumber,count];
//    ([to]=\"%@\" and [type]=\"email\")
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    while([rs next]){
        NSString *to=[rs stringForColumn:@"to"];
        IMMessage * message=[[IMMessage alloc] init];
//        if([jid isEqualToString:to]){
//            
//            message.ID=[rs stringForColumn:@"msgID"];
//            message.from=[rs stringForColumn:@"from"];
//            message.to=to;
//            message.body=[rs stringForColumn:@"body"];
//            message.type=[rs stringForColumn:@"type"];
//            message.date=[Tool getDisplayTime:[rs stringForColumn:@"date"]];
//            message.isneedsend=[rs stringForColumn:@"isneedsend"];
//        }
        message.ID=[rs stringForColumn:@"msgID"];
        message.from=[rs stringForColumn:@"from"];
        message.to=to;
        message.body=[rs stringForColumn:@"body"];
        message.type=[rs stringForColumn:@"type"];
//        message.date=[Tool getDisplayTime:[rs stringForColumn:@"date"]];
        message.date=[rs stringForColumn:@"date"];
        NSLog(@"%@",[rs stringForColumn:@"date"]);
        message.isneedsend=[rs stringForColumn:@"isneedsend"];
        [array addObject:message];
    }
    [rs close];
    rs=nil;
    return array;
}

//聊天列表
+(NSMutableArray*)getChatlistModle
{

    BOOL flag=false;
     NSMutableArray* chatuserlist=[[NSMutableArray alloc] init];
     NSString * sql=@"select * from  (select *from [User]  where isactive=\"1\"  ) as b left join [Message] as s ON b.msgID=s.msgID order by [date] desc";
    FMResultSet *rs=[FMDBDao executeQuery:sql] ;
    while ([rs next]){
        
        IMChatListModle * tempuser=[[IMChatListModle alloc]init];
        tempuser.jidstr=[rs stringForColumn:@"jidstr"];
        tempuser.nick=[rs stringForColumn:@"nick"];
        tempuser.localname=[rs stringForColumn:@"localname"];
        tempuser.phonenumber=[rs stringForColumn:@"phonenumber"];
        tempuser.faceurl=[rs stringForColumn:@"faceurl"];
        tempuser.group=[rs stringForColumn:@"group"];
        tempuser.update=[rs stringForColumn:@"update"];
        tempuser.state=[rs stringForColumn:@"state"];
        tempuser.isimrea=[rs stringForColumn:@"isimrea"];
        tempuser.isRoom=[rs stringForColumn:@"isRoom"];
        tempuser.isCreatMe=[rs stringForColumn:@"isCreatMe"];
        tempuser.tempText=[rs stringForColumn:@"temptext"];
        tempuser.isNeedTip=[rs stringForColumn:@"isNeedTips"];
        tempuser.accouttype=[rs stringForColumn:@"accounttype"];
        
        IMMessage * temp=[[IMMessage alloc] init];
        temp.ID=[rs stringForColumn:@"msgID"];
        temp.from=[rs stringForColumn:@"from"];
        temp.to=[rs stringForColumn:@"to"];
        temp.body=[rs stringForColumn:@"body"];
        NSString *type=[rs stringForColumn:@"type"];
        temp.type=type;
        temp.date=[Tool getDisplayTime:[rs stringForColumn:@"date"]];//[rs stringForColumn:@"date"];
        // temp.isread=[rs stringForColumn:@"isread"];
        temp.isneedsend=[rs stringForColumn:@"isneedsend"];
        
        
        tempuser.messagebody=temp;
        [temp autorelease];
        tempuser.messageCount=[rs stringForColumn:@"unreadcount"];
        tempuser.unreadcount=[rs stringForColumn:@"unreadcount"];
        if (tempuser) {
            [chatuserlist addObject:tempuser];
        }
        
      
        [tempuser autorelease];
    }
    [rs close];
    rs=nil;
    [chatuserlist autorelease];
    return chatuserlist;
}

+(NSMutableArray*)getContactsListModle
{
    
  //  [self sharedFMDBManager];
    
    //select * from User  order by [isloc] desc, [update] desc,[device] desc
    
    NSMutableArray* chatuserlist=[[NSMutableArray alloc] init];
   // NSString * sql=@"select * from User where isimrea=\"1\"  or isloc=\"1\" order by [update] desc,[device] desc";
    //群聊
    NSString * sql=@"select * from User  where isRoom='0'  order by [isloc] desc,localname,[device] desc";
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    
    while ([rs next]){
        
         IMChatListModle* tempuser=[[IMChatListModle alloc]init];
        
        
        //
      //  NSString *jidstr=[rs stringForColumn:@"jidstr"];
        tempuser.jidstr=[rs stringForColumn:@"jidstr"];
        tempuser.nick=[rs stringForColumn:@"nick"];
        tempuser.localname=[rs stringForColumn:@"localname"];
        tempuser.localname=tempuser.localname?tempuser.localname:[[tempuser.jidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
      //  tempuser.addrefID=[rs stringForColumn:@"addrefID"];
        tempuser.phonenumber=[rs stringForColumn:@"phonenumber"];
        tempuser.faceurl=[rs stringForColumn:@"faceurl"];
        tempuser.group=[rs stringForColumn:@"group"];
        tempuser.update=[rs stringForColumn:@"update"];
        tempuser.device=[rs stringForColumn:@"device"];
        tempuser.state=[rs stringForColumn:@"state"];
        tempuser.isimrea=[rs stringForColumn:@"isimrea"];
        tempuser.isloc=[rs stringForColumn:@"isloc"];
         tempuser.isactive=[rs stringForColumn:@"isactive"];
        tempuser.isRoom=[rs stringForColumn:@"isRoom"];
        tempuser.tempText=[rs stringForColumn:@"temptext"];
        tempuser.phoneown=[rs stringForColumn:@"phonetitle"];
        [chatuserlist addObject:tempuser];
        
        [tempuser autorelease];
    }
    [rs close];

    [chatuserlist autorelease];
    return chatuserlist;
    
}

+(NSMutableArray*)getAllUserbyUpdateDesc
{
    
    //[self sharedFMDBManager];
    NSMutableArray* chatuserlist=[[NSMutableArray alloc] init];
    NSString * sql=@"select * from User  order by [update] desc";
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    
    while ([rs next]){
        
        IMUser* tempuser=[[IMUser alloc]init];
        tempuser.jidstr=[rs stringForColumn:@"jidstr"];
        tempuser.isimrea=[rs stringForColumn:@"isimrea"];
        tempuser.isloc=[rs stringForColumn:@"isloc"];
        [chatuserlist addObject:tempuser];
        
        [tempuser autorelease];
    }
    [rs close];
    [chatuserlist autorelease];
    return chatuserlist;

}

+  (void) saveUserLocalNick:(NSString *) jibstr  isImrea:(NSString *) isrea
{
    NSString * jidstr=[jibstr stringByAppendingString:XMPPSERVER2];
    NSString * sql=[NSString stringWithFormat:@"update User set isloc=\"%@\" WHERE jidstr = \"%@\"",isrea,jidstr];
    [FMDBDao executeUpdate:sql];
   
}

+  (void) saveUserLocalNick:(NSString *) phone image:(NSString *) nickname addid:(NSString *)addid  isImrea:(NSString *) isrea phonetitle:(NSString *)title
{
    NSString * cjidstr=[phone stringByAppendingString:XMPPSERVER2];
    NSString * sql=[NSString stringWithFormat:@"insert into User(jidstr,localname,isloc, addrefID,phonenumber,phonetitle) values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",cjidstr,nickname,isrea,addid,phone,title];//phonetitle
    

        BOOL flag=[FMDBDao executeUpdate:sql];
        if (!flag) {
            sql=[NSString stringWithFormat:@"update User set localname =\"%@\" , addrefID = \"%@\", phonetitle = \"%@\" ,phonenumber= \"%@\"   WHERE jidstr = \"%@\" ",nickname,addid,title,phone,cjidstr];
            
            NSLog(@"%@",sql);
          flag=[FMDBDao executeUpdate:sql];
        }
}

+(NSMutableArray*)getMessageByFormAndToJidstr:(NSString *)fromjidstr Tojidstr:(NSString*)tojidstr withRowCount:(NSString *)rowcount
{
   NSMutableArray* messagelist=[[NSMutableArray alloc] init];
    NSString * sql=[NSString stringWithFormat:@"select * from (      select * from (        select a.*,b.localname from (  select * from Message where  ([from] =\"%@\" and [to] =\"%@\") or ([from] =\"%@\" and [to] =\"%@\") )  a left join [user] b on a.[from]=b.jidstr    order by [date] desc ) as ms  limit 0,%@  )  order by [date]",fromjidstr ,tojidstr,tojidstr,fromjidstr,rowcount];
    
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    
    BOOL istoday=true;
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    [dateformatter autorelease];
    
    while ([rs next]){
        
        IMMessage * temp=[[IMMessage alloc] init];
        temp.ID=[rs stringForColumn:@"msgID"];
        temp.from=[rs stringForColumn:@"from"];
        temp.localname=[rs stringForColumn:@"localname"];
        temp.to=[rs stringForColumn:@"to"];
        temp.body=[rs stringForColumn:@"body"];
        temp.type=[rs stringForColumn:@"type"];
        temp.date=[rs stringForColumn:@"date"];
        temp.isneedsend=[rs stringForColumn:@"isneedsend"];
        temp.isaccpet=[rs stringForColumn:@"isaccpet"];
        
        IMMessage * temptime=[[IMMessage alloc] init];
        NSString * tpt=[Tool getYYYYMMDD:temp.date];
        if (![locationString isEqualToString:tpt] && ![Tool compareDate:temp.date]==0) {
            temptime.type=@"time";
            temptime.body=tpt;
            [messagelist addObject:temptime];
            locationString=tpt;
        }
        if (istoday &&  [Tool compareDate:temp.date]==0) {
            temptime.type=@"time";
            temptime.body=NSLocalizedString(@"lbtoday",nil);//今天
            [messagelist addObject:temptime];
            istoday=false;
        }
        [messagelist addObject:temp];
        [temp autorelease];
        [temptime autorelease];
    }
    
    [rs close];
    rs=nil;
    [messagelist autorelease];
    return messagelist;
}

#pragma 获取聊天记录
//为第二套聊天界面做的修改
+(NSMutableArray*)getMessageByFormAndToJidstr2:(NSString *)fromjidstr Tojidstr:(NSString*)tojidstr withRowCount:(NSString *)rowcount
{
    NSMutableArray* messagelist=[[NSMutableArray alloc] init];
    NSString * sql=[NSString stringWithFormat:@"select * from (      select * from (        select a.*,b.localname,b.faceurl from (  select * from Message where  ([from] =\"%@\" and [to] =\"%@\") or ([from] =\"%@\" and [to] =\"%@\") )  a left join [user] b on a.[from]=b.jidstr    order by [date] desc ) as ms  limit 0,%@  )  order by [date]",fromjidstr ,tojidstr,tojidstr,fromjidstr,rowcount];
    
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    
    BOOL istoday=true;
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *  locationString= [dateformatter stringFromDate:senddate];
    
    [dateformatter autorelease];
    
   NSString *  myjidstr=[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
    int count=0;
    while ([rs next]){
        count++;
        NSLog(@"%d",count);
        MessageModel * temp=[[MessageModel alloc] init];
        temp.ID=[rs stringForColumn:@"msgID"];
        NSString * tojidstr=[rs stringForColumn:@"to"];
        temp.isFromMe=false;
        if ([tojidstr rangeOfString:myjidstr].location ==NSNotFound) {
            temp.isFromMe=true;
        }
        NSString * data=[rs stringForColumn:@"date"];
        temp.time=[Tool getHHMM:data];
         temp.faceurl=[rs stringForColumn:@"faceurl"];
       
        temp.isNeedSend=[rs stringForColumn:@"isneedsend"];
        temp.isReceived=[rs stringForColumn:@"isaccpet"];
        NSString * localname=[rs stringForColumn:@"localname"];
        NSString * from=[rs stringForColumn:@"from"];
        temp.username=localname?localname:[[from componentsSeparatedByString:@"@"] objectAtIndex:0];
        NSString * type=[rs stringForColumn:@"type"];
        
        if([type isEqualToString:EMAIL]){
            
            NSLog(@"%@",[rs stringForColumn:@"body"]);
            temp.content=[rs stringForColumn:@"body"];
            temp.type=MessageTypeEmail;
        }else if ([type isEqualToString:@"chat"]) {
             temp.content=[rs stringForColumn:@"body"];
            temp.type=MessageTypeText;
        }else if([type isEqualToString:@"img"]){
             temp.content=[rs stringForColumn:@"body"];
            temp.type=MessageTypePicture;
        }else if([type isEqualToString:@"voice"]){
             temp.content=[rs stringForColumn:@"voicelenth"];
             temp.voicepath=[rs stringForColumn:@"body"];
           temp.type=MessageTypeVoice;
        }else if([type isEqualToString:@"tips"]){
             temp.content=[rs stringForColumn:@"body"];
          temp.type=MessageTypeTips;
        }else{
             temp.content=[rs stringForColumn:@"body"];
             temp.type=MessageTypeTime;
        }
        
        MessageModel * temptime=[[MessageModel alloc] init];
        NSString * tpt=[Tool getYYYYMMDD:data];
        if (![locationString isEqualToString:tpt] && ![Tool compareDate:data]==0) {
            temptime.type=MessageTypeTime;
            temptime.content=tpt;
            [messagelist addObject:temptime];
            locationString=tpt;
        }
        if (istoday &&  [Tool compareDate:data]==0) {
            temptime.type=MessageTypeTime;
            temptime.content=NSLocalizedString(@"lbtoday",nil);//今天
            [messagelist addObject:temptime];
            istoday=false;
        }
        [messagelist addObject:temp];
        [temptime autorelease];
        [temp autorelease];
    }
    
    [rs close];
    rs=nil;
    [messagelist autorelease];
    return messagelist;
}

+(void)updateEmailID:(NSString *)msgID WithJID:(NSString *)jid{
    NSString *sql=[NSString stringWithFormat:@"update [User] set msgID=\"%@\" where jidstr= \"%@\" ",msgID,jid];
    BOOL flag= [FMDBDao executeUpdate:sql];
    if (!flag) {
        sql=[NSString stringWithFormat:@"insert into [User](jidstr,[msgID]) values(\"%@\",\"%@\")",msgID,jid];
        [FMDBDao executeUpdate:sql];
    }
}

+ (void) saveMessage2:(NSString *) from to:(NSString *) to body:(NSString *) body type:(NSString *) type date:(NSString *)date voicelenth:(NSString *)lenth msgID:(NSString *) msgID
{
    NSString * sql=[NSString stringWithFormat:@"insert into Message([msgID],[from],[to],[body],[type],[date],[isneedsend],[isaccpet],[voicelenth]) values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",msgID,from,to,body,type,date,@"2",@"0",lenth];
        [FMDBDao executeUpdate:sql];
        sql=[NSString stringWithFormat:@"update [User] set msgID=\"%@\" where jidstr= \"%@\" ",msgID,to];
        BOOL flag= [FMDBDao executeUpdate:sql];
        if (!flag) {
            sql=[NSString stringWithFormat:@"insert into [User](jidstr,[msgID]) values(\"%@\",\"%@\")",msgID,to];
           [FMDBDao executeUpdate:sql];
        }
}

+ (void) setMessageRead:(NSString*)formjidstr needactive:(BOOL)flag
{
    NSString * needactive=@"0";
    if (flag) {
        needactive=@"1";
    }
    NSString * sqlstr=[NSString stringWithFormat:@"update User set isactive=\"%@\" ,unreadcount=\"%@\"  where [jidstr] =\"%@\"  ",needactive,@"0",formjidstr];
    [FMDBDao executeUpdate:sqlstr];

}

+  (void) updatesendstate:(NSString*) msgID  isNeedSend:(NSString *)state
{
       NSString * sql=[NSString stringWithFormat:@"update [Message] set [isneedsend]= \"%@\"  where msgID=\"%@\"",state,msgID];
        [FMDBDao executeUpdate:sql];
}

//获取所有已经是talkking的用户(已经加了国家代码前缀)
+(NSMutableArray*)getAllactiveUser
{
    
    NSMutableArray* chatuserlist=[[NSMutableArray alloc] init];
    NSString * sql=@"select * from User where isRoom=\"0\" and ( isimrea=\"1\"  or isloc=\"1\") and (jidstr is not null) order by [update] desc";
    
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    
    while ([rs next]){
        
        IMChatListModle * tempuser=[[IMChatListModle alloc]init];
        tempuser.jidstr=[rs stringForColumn:@"jidstr"];
        tempuser.nick=[rs stringForColumn:@"nick"];
        tempuser.localname=[rs stringForColumn:@"localname"];
        tempuser.phonenumber=[rs stringForColumn:@"phonenumber"];
        tempuser.faceurl=[rs stringForColumn:@"faceurl"];
        tempuser.group=[rs stringForColumn:@"group"];
        tempuser.update=[rs stringForColumn:@"update"];
        tempuser.device=[rs stringForColumn:@"device"];
        tempuser.state=[rs stringForColumn:@"state"];
        tempuser.isimrea=[rs stringForColumn:@"isimrea"];
        tempuser.isloc=[rs stringForColumn:@"isloc"];
        tempuser.isRoom=[rs stringForColumn:@"isRoom"];
        [chatuserlist addObject:tempuser];
        
        [tempuser autorelease];
    }
    [rs close];
    rs=nil;
    [chatuserlist autorelease];
    return chatuserlist;
}

//聊天室的所有数据库操作

//创建一个聊天室
+(BOOL)creatChatRoom:(NSString *)roomjidstr nick:(NSString *)nick subject:(NSString *)subject faceurl:(NSString *) facurl isMeCreat:(NSString*)isCreatMe
{
    
    NSString * sql;
    
    if (facurl) {
        sql=[NSString stringWithFormat:@"insert into User([jidstr],[nick],[localname],[faceurl],[isRoom],[isactive],[isCreatMe]) values(\"%@\",\"%@\",\"%@\",\"%@\" ,\"%@\",\"%@\",\"%@\")",roomjidstr,nick,subject,facurl,@"1",@"1",isCreatMe];
    }else{
       sql=[NSString stringWithFormat:@"insert into User([jidstr],[nick],[localname],[isRoom],[isactive],[isCreatMe]) values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",roomjidstr,nick,subject,@"1",@"1",isCreatMe];
    }
    
    BOOL flag= [FMDBDao executeUpdate:sql];
    if (!flag) { //当收到邀请的时候可能这个群是以前自己创建的但是被自己销毁了，现在存在里面的人邀请自己
         sql=[NSString stringWithFormat:@"update [user] set [isimrea]= \"%@\",[isCreatMe]=\"%@\"  where jidstr=\"%@\"",@"0",@"0",roomjidstr];
        [FMDBDao executeUpdate:sql];
    }
    return flag;
}
//往房间里添加新的成员
+(BOOL)addRoomUser:(NSString *)roomjidstr userjidstr:(NSString *)userjidstr role:(NSString *)role
{
    NSString * sql=[NSString stringWithFormat:@"insert into RoomList([roomjidstr],[userjidstr],[role]) values(\"%@\",\"%@\",\"%@\")",roomjidstr,userjidstr,role];
    BOOL flag= [FMDBDao executeUpdate:sql];
    return flag;
}

+ (BOOL)SaveGroupMessage:(NSString *)msgID  fromjidstr:(NSString *)formjidstr tojidstr:(NSString *)tojidstr body:(NSString *)body type:(NSString *)type date:(NSString *)date groupfrom:(NSString *)groupfrom

{
    NSString * sql;
    
    if (date) {
        sql=[NSString stringWithFormat:@"insert into Message([msgID],[from],[to],[body],[type],[groupfrom],[date],[isaccpet]) values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",msgID,formjidstr,tojidstr,body,type,groupfrom,date,@"1"];
    }else{
         sql=[NSString stringWithFormat:@"insert into Message([msgID],[from],[to],[body],[type],[groupfrom],[isaccpet]) values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",msgID,formjidstr,tojidstr,body,type,groupfrom,@"1"];
    }
  bool flag =[FMDBDao executeUpdate:sql];
    sql=[NSString stringWithFormat:@"update [User] set msgID=\"%@\" where jidstr= \"%@\" ",msgID,formjidstr];
    [FMDBDao executeUpdate:sql];
    
    return flag;

    

}

+ (BOOL)SaveGroupMessage2:(NSString *)msgID  fromjidstr:(NSString *)formjidstr tojidstr:(NSString *)tojidstr body:(NSString *)body type:(NSString *)type date:(NSString *)date groupfrom:(NSString *)groupfrom voicelenth:(NSString *)voicelenth

{
    NSString * sql;
    
    if (date) {
        sql=[NSString stringWithFormat:@"insert into Message([msgID],[from],[to],[body],[type],[groupfrom],[date],[isaccpet],[voicelenth]) values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",msgID,formjidstr,tojidstr,body,type,groupfrom,date,@"1",voicelenth];
    }else{
        sql=[NSString stringWithFormat:@"insert into Message([msgID],[from],[to],[body],[type],[groupfrom],[isaccpet],[voicelenth]) values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",msgID,formjidstr,tojidstr,body,type,groupfrom,@"1",voicelenth];
    }
    bool flag =[FMDBDao executeUpdate:sql];
    return flag;
}


+(NSMutableArray*)getAllLocalUser
{
    
    
    NSMutableArray* chatuserlist=[[NSMutableArray alloc] init] ;
    NSString * sql=@"select * from User where isloc=\"1\" order by [update] desc";
    
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    
    while ([rs next]){
        
        IMChatListModle * tempuser=[[IMChatListModle alloc]init];
        tempuser.jidstr=[rs stringForColumn:@"jidstr"];
        tempuser.isloc=[rs stringForColumn:@"isloc"];
        [chatuserlist addObject:tempuser];
        
        [tempuser autorelease];
    }
    [rs close];
    rs=nil;
    
    [chatuserlist autorelease];
    
    return chatuserlist;


}

+(NSMutableArray*)getChatRoomMessage:(NSString *)roomjidstr rowCount:(NSString *)rowcount
{
    NSMutableArray* messagelist=[[NSMutableArray alloc] init];
    NSString * sql=[NSString stringWithFormat:@" select tt.*,uu.jidstr,uu.localname,uu.faceurl from  ( select * from (  select * from Message   where ([from] =\"%@\" or [to] =\"%@\")  order by [date] desc)   as ms  limit 0,%@) as tt left join [User]  as uu on tt.groupfrom=uu.jidstr order by tt.date",roomjidstr,roomjidstr,rowcount];
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    BOOL istoday=true;
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    [dateformatter autorelease];
    
    while ([rs next]){
        
        IMMessage * temp=[[IMMessage alloc] init];
        temp.ID=[rs stringForColumn:@"msgID"];
        temp.from=[rs stringForColumn:@"from"];
        temp.to=[rs stringForColumn:@"to"];
        temp.body=[rs stringForColumn:@"body"];
        temp.type=[rs stringForColumn:@"type"];
        temp.groupfrom=[rs stringForColumn:@"groupfrom"];
        temp.date=[rs stringForColumn:@"date"];
        temp.isneedsend=[rs stringForColumn:@"isneedsend"];
        temp.isaccpet=[rs stringForColumn:@"isaccpet"];
        
        //人物信息
        temp.jidstr=[rs stringForColumn:@"jidstr"];
        temp.localname=[rs stringForColumn:@"localname"];
        temp.faceurl=[rs stringForColumn:@"faceurl"];
        
        IMMessage * temptime=[[IMMessage alloc] init];
         NSString * tpt=[Tool getStringToIndex10:temp.date];
        if (![locationString isEqualToString:tpt] && ![Tool compareDate:temp.date]==0) {
            temptime.type=@"time";
            temptime.body=tpt;
            [messagelist addObject:temptime];
            locationString=tpt;
        }
        if (istoday &&  [Tool compareDate:temp.date]==0) {
            temptime.type=@"time";
            temptime.body=NSLocalizedString(@"lbtoday",nil);//今天
            [messagelist addObject:temptime];
            istoday=false;
        }
        
        [messagelist addObject:temp];
        
        [temptime autorelease];
        [temp autorelease];
    }
    
    [rs close];
    rs=nil;
    [messagelist autorelease];
    return messagelist;
    
}

+(NSMutableArray*)getChatRoomMessage2:(NSString *)roomjidstr rowCount:(NSString *)rowcount
{
    NSMutableArray* messagelist=[[NSMutableArray alloc] init];
    NSString * sql=[NSString stringWithFormat:@" select tt.*,uu.jidstr,uu.localname,uu.faceurl from  ( select * from (  select * from Message   where ( [markdelete]!=\"1\" and ([from] =\"%@\" or [to] =\"%@\"))  order by [date] desc)   as ms  limit 0,%@) as tt left join [User]  as uu on tt.groupfrom=uu.jidstr order by tt.date",roomjidstr,roomjidstr,rowcount];
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    BOOL istoday=true;
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *  locationString= [dateformatter stringFromDate:senddate];
    
    [dateformatter autorelease];
    
    NSString *  myjidstr=[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];

    
    while ([rs next]){
        
        MessageModel * temp=[[MessageModel alloc] init];
        temp.ID=[rs stringForColumn:@"msgID"];
        NSString * tojidstr=[rs stringForColumn:@"to"];
        temp.isFromMe=false;
        if ([tojidstr rangeOfString:myjidstr].location ==NSNotFound) {
            temp.isFromMe=true;
        }
        NSString * data=[rs stringForColumn:@"date"];
        temp.time=[Tool getHHMM:data];
         temp.faceurl=[rs stringForColumn:@"faceurl"];
        temp.isNeedSend=[rs stringForColumn:@"isneedsend"];
        temp.isReceived=[rs stringForColumn:@"isaccpet"];
        NSString * localname=[rs stringForColumn:@"localname"];
        NSString * from=[rs stringForColumn:@"groupfrom"];
        temp.username=[Tool isBlankString:localname]?[[from componentsSeparatedByString:@"@"] objectAtIndex:0]:localname;
        NSString * type=[rs stringForColumn:@"type"];
        
        if ([type isEqualToString:@"chat"]) {
            temp.content=[rs stringForColumn:@"body"];
            temp.type=MessageTypeText;
        }else if([type isEqualToString:@"img"]){
            temp.content=[rs stringForColumn:@"body"];
            temp.type=MessageTypePicture;
        }else if([type isEqualToString:@"voice"]){
            temp.content=[rs stringForColumn:@"voicelenth"];
            temp.voicepath=[rs stringForColumn:@"body"];
            temp.type=MessageTypeVoice;
        }else if([type isEqualToString:@"tips"]){
            temp.content=[rs stringForColumn:@"body"];
            temp.type=MessageTypeTips;
        }else{
            temp.content=[rs stringForColumn:@"body"];
            temp.type=MessageTypeTime;
        }
        
        
        
        MessageModel * temptime=[[MessageModel alloc] init];
        NSString * tpt=[Tool getYYYYMMDD:data];
        if (![locationString isEqualToString:tpt] && ![Tool compareDate:data]==0) {
            temptime.type=MessageTypeTime;
            temptime.content=tpt;
            [messagelist addObject:temptime];
            locationString=tpt;
        }
        if (istoday &&  [Tool compareDate:data]==0) {
            temptime.type=MessageTypeTime;
            temptime.content=NSLocalizedString(@"lbtoday",nil);//今天
            [messagelist addObject:temptime];
            istoday=false;
        }
        
        [messagelist addObject:temp];
        
        [temp autorelease];
        [temptime autorelease];
    }
    
    [rs close];
    rs=nil;
    
    [messagelist autorelease];
    return messagelist;
    
}


+(NSMutableArray *)getAllUser
{
    NSMutableArray* messagelist=[[NSMutableArray alloc] init];
    
    NSString * sql=@"select jidstr , phonenumber,localname from [User] where isloc !=\"1\" and isRoom !=\"1\"";
    
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    while ([rs next]){
        
     NSString * phonenumber=[rs stringForColumn:@"phonenumber"];
     NSString * nickname=[rs stringForColumn:@"localname"];
     NSString * jidstr=[rs stringForColumn:@"jidstr"];
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        [dict setObject:phonenumber forKey:@"phone"];
        [dict setObject:nickname forKey:@"nickname"];
        [dict setObject:jidstr forKey:@"jidstr"];
        [messagelist addObject:dict];
        
        [dict autorelease];
        
    }
    [rs close];
    rs=nil;
    [messagelist autorelease];
    return messagelist;
}

+(void)updateUserIsLocal:(NSString *) indata
{
    NSString * sql=[NSString stringWithFormat:@"update User set isloc='1' where phonenumber in (%@)", indata];
    [FMDBDao executeUpdate:sql];
}

+(void)updateUserIsLocalWithJidstr:(NSString *) jidstr
{
    NSString * sql=[NSString stringWithFormat:@"update User set isloc='1' where jidstr =\"%@\"", jidstr];
    [FMDBDao executeUpdate:sql];
}

+(void)updateRoomFaceurl:(NSString *) faceurl roomjidstr:(NSString *)jidstr
{
    NSString * sql=[NSString stringWithFormat:@"update User set faceurl=\"%@\" where jidstr =\"%@\"", faceurl,jidstr];
    [FMDBDao executeUpdate:sql];
}

+(NSMutableArray*)getAllChatRoom
{
    
    NSMutableArray* chatuserlist=[[NSMutableArray alloc] init];
      NSString * sql=@"select * from User where isRoom=\"1\" and isimrea=\"0\"  order by [update] desc";
    
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    
    while ([rs next]){
        
        IMChatListModle * tempuser=[[IMChatListModle alloc]init];
        tempuser.jidstr=[rs stringForColumn:@"jidstr"];
        tempuser.isNeedTip=[rs stringForColumn:@"isNeedTips"];
        [chatuserlist addObject:tempuser];
        [tempuser autorelease];
    }
    [rs close];
    rs=nil;
    [chatuserlist autorelease];
    return chatuserlist;
    
    
}

+(NSMutableArray *)getOneRoomUser:(NSString *)roomjidstr
{
    NSMutableArray* oneRoomUserlist=[[NSMutableArray alloc] init];
    
    NSString * sql=[NSString stringWithFormat:@"select a.*,b.localname ,b.faceurl from (select * from RoomList where  roomjidstr=\"%@\" order by role desc) a left join User b on a.userjidstr=b.jidstr",roomjidstr];
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    while ([rs next]){
        
        OneRoomUser *temp=[[OneRoomUser alloc] init] ;
       temp.roomjidstr=[rs stringForColumn:@"roomjidstr"];
       temp.userjidstr=[rs stringForColumn:@"userjidstr"];
       temp.role=[rs stringForColumn:@"role"];
       temp.localname=[rs stringForColumn:@"b.localname"];
       temp.faceurl=[rs stringForColumn:@"b.faceurl"];

        [oneRoomUserlist addObject:temp];
        
        [temp autorelease];
        
    }
    [rs close];
    rs=nil;
    [oneRoomUserlist autorelease];
    return oneRoomUserlist;
}

+(BOOL)deleteRoomUser:(NSString *)roomjidstr userjidstr:(NSString *)userjidstr
{
    BOOL flag=false;
    
    
    NSString * sql=[NSString stringWithFormat:@"delete  from RoomList where roomjidstr=\"%@\" and userjidstr=\"%@\"", roomjidstr,userjidstr];
   flag = [FMDBDao executeUpdate:sql];
    return flag;
}
//删除用户包含房间 同时会把相关的消息删除
+(BOOL)deleteUser:(NSString *)jidstr
{
    BOOL flag=false;
    NSString * sql=[NSString stringWithFormat:@"delete  from User where jidstr=\"%@\" ",jidstr];
    flag = [FMDBDao executeUpdate:sql];
     sql=[NSString stringWithFormat:@"delete  from Message where [from]=\"%@\" or [to]=\"%@\"  ",jidstr,jidstr];
      [FMDBDao executeUpdate:sql];
    return flag;
}

//当自己被提出房间或者加入的群被销毁时执行
+  (void) setNotinRoom:(NSString*) jidstr
{
    NSString * sql=[NSString stringWithFormat:@"update [user] set [isimrea]= \"%@\"  where jidstr=\"%@\"",@"1",jidstr];
    [FMDBDao executeUpdate:sql];
}


//当创建人把群删除是 变更为自己的
+  (void) setRoomisMy:(NSString*) jidstr
{
    NSString * sql=[NSString stringWithFormat:@"update [user] set [isCreatMe]= \"%@\"  where jidstr=\"%@\"",@"1",jidstr];
    [FMDBDao executeUpdate:sql];
}

//存储最后一条未发送的消息
+  (void) setTempText:(NSString*) jidstr text:(NSString *)text
{
    NSString * sql=[NSString stringWithFormat:@"update [user] set [temptext]= \"%@\"  where jidstr=\"%@\"",text,jidstr];
    [FMDBDao executeUpdate:sql];
}

+  (BOOL) deleteOneMessageWithID:(NSString *)msgID
{
     BOOL flag=false;
    NSString * sql=[NSString stringWithFormat:@"delete from Message where msgID=\"%@\"",msgID];
    flag=[FMDBDao executeUpdate:sql];
    return flag;
}
+  (BOOL) markDeleteOneMessageWithID:(NSString *)msgID
{
    BOOL flag=false;
    NSString * sql=[NSString stringWithFormat:@"update [Message] set [markdelete]= \"%@\"  where msgID=\"%@\"",@"1",msgID];
    flag=[FMDBDao executeUpdate:sql];
    return flag;
}

+(void)updateRoomLocalname:(NSString *)jidstr nickname:(NSString *)nick
{
    NSString * sql=[NSString stringWithFormat:@"update [User] set [nick]=\"%@\" where jidstr=\"%@\"",nick,jidstr];
    [FMDBDao executeUpdate:sql];
}

+(NSInteger)getRoomUserCount:(NSString *)jidstr
{
    NSInteger count=0;
    
    NSString * sql=[NSString stringWithFormat:@"select count(*) as usercount from RoomList where roomjidstr=\"%@\"",jidstr];
    FMResultSet *rs=[FMDBDao executeQuery:sql];
    while ([rs next]){
      count=[rs intForColumn:@"usercount"];
    }
    [rs close];
    rs=nil;
    return count;
}

+(BOOL)updateNotShow:(NSString*)jidstr{
    
    BOOL flag;
    NSString * sql=[NSString stringWithFormat:@"update [User] set [isactive]=\"0\" where jidstr=\"%@\"",jidstr];
   flag=[FMDBDao executeUpdate:sql];
    return flag;
}

+(BOOL)setUserNeedTips:(NSString*)jidstr vaule:(NSString*)vaule{
    
    BOOL flag;
    NSString * sql=[NSString stringWithFormat:@"update [User] set [isNeedTips]=\"%@\" where jidstr=\"%@\"",vaule,jidstr];
    flag=[FMDBDao executeUpdate:sql];
    return flag;
}

@end