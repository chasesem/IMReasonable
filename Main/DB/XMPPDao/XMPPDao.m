///
//  XMPPDao.m
//  IMReasonable
//
//  Created by apple on 15/3/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "XMPPDao.h"
#import "XMPPFramework.h"
#import "AnimationHelper.h"
#import "DeviceHard.h"
#import "IMMessage.h"
#import "ASIFormDataRequest.h"

@interface XMPPDao()

//没有网络时用于定时重连的定时器
@property(nonatomic,strong)NSTimer *timer;
//重连定时器是否开启了
@property(nonatomic,assign)BOOL hasStartTimer;

@end

@implementation XMPPDao {

    NSString* deleteUser;
}

static NSMutableArray* allRoom;

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize isConnectInternet;
@synthesize isReg;

-(NSTimer *)timer{
    if(!_timer){
        
        _timer=[NSTimer  timerWithTimeInterval:6.0 target:self selector:@selector(repeatConnect:)userInfo:nil repeats:YES];
        [[NSRunLoop  currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    return _timer;
}

-(void)repeatConnect:(NSTimer *)timer{
    [self connect];
    NSLog(@"repeatConnect");
}

+ (XMPPDao*)sharedXMPPManager
{
    static XMPPDao* sharedXMPPManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedXMPPManager = [[self alloc] init];
    });
    return sharedXMPPManager;
}



- (id)init
{
    self = [super init];
    if (self) {
        [XMPPDao GetAllRoom];
        xmppStream = [[XMPPStream alloc] init];
        xmppStream.enableBackgroundingOnSocket = YES; //开启后台接收消息
        xmppReconnect = [[XMPPReconnect alloc] init];
        [xmppReconnect activate:xmppStream];
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

        self.reachability = [Reachability reachabilityWithHostName:@"www.talk-king.net"];
        [self.reachability startNotifier];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChangedT:) name:kReachabilityChangedNotification object:nil];

        //初始化所有的表格
    }
    return self;
}
+ (void)GetAllRoom
{
    allRoom = [IMReasonableDao getAllChatRoom];
}

- (void)dealloc
{
    [self teardownStream];
}
- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppReconnect deactivate];
    [xmppStream disconnect];
    xmppStream = nil;
    xmppReconnect = nil;
}

//网络通知的状态
- (void)reachabilityChangedT:(NSNotification*)note
{
    Reachability* currReach = [note object];
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    NetworkStatus status = [currReach currentReachabilityStatus];

    if (status == NotReachable) {
        self.isConnectInternet = NO;
        NSLog(@"没网啊");
        [self.internetConnectDelegate isConnectToInternet:NO];
        //return;
    }

    if (status == kReachableViaWiFi || status == kReachableViaWWAN) {
        self.isConnectInternet = YES;
        NSLog(@"有网啊");
        [self.internetConnectDelegate isConnectToInternet:YES];
    }

    [[NSNotificationCenter defaultCenter]
        //网络状态发生变化
        postNotificationName:@"NETCHANGE"
                      object:self];
}

#pragma mark -上线
- (void)goOnline
{
    XMPPPresence* presence = [XMPPPresence presence]; // type="available" is implicit
    [[self xmppStream] sendElement:presence];
    //    NSLog(@"-------%@",presence);
    [self SendDevicetoken];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    NSString* name = [defaults objectForKey:MyLOCALNICKNAME];

    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    bool isFirstGetLocal = [defaults boolForKey:[NSString stringWithFormat:@"%@%@", version, @"LOCUSER"]];
    if (isFirstGetLocal && (![Tool isBlankString:name])) {
        [[XMPPDao sharedXMPPManager] SetMyPushName:name];
    }

    BOOL flag = [defaults boolForKey:USERELISTNEED]; //程序第一次登录去服务器拉取一次联系人
    if (!flag) { //第一次登陆的时候请求服务器端的联系人
        [self queryOneRoster:[defaults objectForKey:XMPPREASONABLEJID]];
        // [self  queryRoster];
        [defaults setBool:true forKey:USERELISTNEED];
        [defaults synchronize];
    }
}

- (void)goOffline
{
    XMPPPresence* presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -传教连接
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{

    if (![xmppStream isDisconnected]) { //如果连接上就返回
        NSLog(@"已连接请直接上线");
        if(_timer){
            
            [_timer invalidate];
            _timer=nil;
            self.hasStartTimer=false;
            NSLog(@"重新连上，定时器关闭");
        }
        [self goOnline];
        return YES;
    }
    NSLog(@"连接中");
    NSString* myJID = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
    NSString* myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEPWD];
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    NSString* device = [DeviceHard deviceString];
    [[NSUserDefaults standardUserDefaults] setObject:[myJID stringByAppendingFormat:@"/%@", device] forKey:XMPPREASONABLEFULLJID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    XMPPJID* myxmppjid = [XMPPJID jidWithString:myJID resource:device];
    [xmppStream setMyJID:myxmppjid];
    [xmppStream setHostName:XMPPSERVER];
    [xmppStream setHostPort:[HOSTVAULE intValue]];

    password = myPassword;
    NSError* error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        return NO;
    }

    return YES;
}

- (void)disconnect
{

    if (xmppStream != nil) {

        if ([xmppStream isConnected]) {
            [self goOffline];
            [xmppStream disconnect];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -建立连接后验证用户密码
- (void)xmppStreamDidConnect:(XMPPStream*)sender
{
    NSLog(@"xmppStreamDidConnect");

    NSError* error = nil;
    NSString* pwd = [[NSUserDefaults standardUserDefaults] objectForKey:XMPPREASONABLEPWD];
    if (isReg) {

        if (![xmppStream registerWithPassword:pwd error:&error]) {
        }
    }
    else {

        if (![[self xmppStream] authenticateWithPassword:pwd error:&error]) {
            NSLog(@"xmppStreamDidConnect ERR");
        }
    }
}



- (void)xmppStreamDidDisconnect:(XMPPStream*)sender withError:(NSError*)error
{
    NSLog(@"连接出错%@", error);

    [AnimationHelper removeHUD];
    self.isLogin = false;

    if (!isXmppConnected) {
        NSLog(@"连接出错");

        if(!self.hasStartTimer){
            
            [self.timer fire];
            self.hasStartTimer=true;
        }
//        [self connect];
    }
}

#pragma mark -验证密码成功后发送上线状态
- (void)xmppStreamDidAuthenticate:(XMPPStream*)sender
{
    NSLog(@"密码验证成功");
    NSString* fulljidstr = [[NSUserDefaults standardUserDefaults] objectForKey:XMPPREASONABLEFULLJID];
    [self querySetMyCarbons:fulljidstr]; //设置多段登陆并转发消息
    [self goOnline]; //上线
    self.isLogin = true;

    [self.authloginDelegate isSuccLogin:true];
    [self allRoomGoOnline];
}
#pragma mark -登陆所有自己的房间
- (void)allRoomGoOnline
{
    //
    if ([XMPPDao sharedXMPPManager].xmppStream.isConnected) {
        NSMutableArray* allChatRoom = [IMReasonableDao getAllChatRoom];
        for (int i = 0; i < allChatRoom.count; i++) {

            IMChatListModle* temp = [allChatRoom objectAtIndex:i];
            [[XMPPDao sharedXMPPManager] loginChatRoom:temp.jidstr];
        }
    }
}
#pragma mark -账号密码验证不成功
- (void)xmppStream:(XMPPStream*)sender didNotAuthenticate:(NSXMLElement*)error
{
    [AnimationHelper removeHUD];
    NSLog(@"密码验证不成功%@", error);
    [self.authloginDelegate isSuccLogin:false];
}
//获取查询结果的
- (BOOL)xmppStream:(XMPPStream*)sender didReceiveIQ:(XMPPIQ*)iq
{
    //NSLog(@"didReceiveIQ ==%@",iq);
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        [self doIQ:iq];
    });
    return YES;
}

- (void)doIQ:(XMPPIQ*)iq
{

    NSString* iqid = [iq attributeStringValueForName:@"id"];

    if (iq.isResultIQ) {

        if ([iq.from.bare isEqualToString:iq.to.bare]) {
            self.isConnectInternet = YES;
            [self.internetConnectDelegate isConnectToInternet:YES];
        }

        NSXMLElement* query = iq.childElement;

        // 直接去聊天服务器拿到群成员
        if ([iqid isEqualToString:@"IOSROOMLIST"] && [@"query" isEqualToString:query.name]) {

            NSLog(@"%@", iq);

            NSArray* items = [query children];
            for (NSXMLElement* item in items) {
                NSString* jib = [item attributeStringValueForName:@"jid"];
                // NSString * role=[item attributeStringValueForName:@"role"];
                NSString* role = [item attributeStringValueForName:@"affiliation"];
                if ([role isEqualToString:@"owner"]) {
                    role = @"1";
                }
                else {
                    role = @"0";
                }
                [IMReasonableDao addRoomUser:iq.fromStr userjidstr:jib role:role];
            }

            return;
        }
        if ([iqid isEqualToString:@"vc1"]) {
            [self photoChange];
        }
        //获取加入或者创建的所有房间ALLROOMS//

        if ([iqid isEqualToString:@"ALLROOMS"] && [@"query" isEqualToString:query.name]) {

            NSArray* items = [query children];
            for (NSXMLElement* item in items) {
                NSString* jib = [item attributeStringValueForName:@"jid"];
                [self GetRoomInfo:jib];
            }

            return;
        }
        //把群添加本地数据库
        if ([iqid isEqualToString:@"ONEROOMINFO"] && [@"query" isEqualToString:query.name]) {

            NSXMLElement* identity = [query elementForName:@"identity"];
            NSString* name = [identity attributeStringValueForName:@"name"];
            NSLog(@"群的名字-----%@", name);
            [IMReasonableDao creatChatRoom:iq.fromStr nick:@"您" subject:name faceurl:@"" isMeCreat:@"0"];
            [[XMPPDao sharedXMPPManager] loginChatRoom:iq.fromStr]; //加入群
            return;
        }

        //获取通讯录里面是注册的用户
        if ([iqid isEqualToString:@"ISUSER"] && [@"query" isEqualToString:query.name]) {

            NSArray* items = [query children];
            for (NSXMLElement* item in items) {
                NSString* jib = [item attributeStringValueForName:@"jid"];
                [self XMPPAddFriendSubscribe2:jib];
                [self queryOneRoster:jib];
                [IMReasonableDao updateUserIsLocalWithJidstr:jib];
            }

            NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"2", @"action", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CONNECTSCHANGE"
                                                                object:self
                                                              userInfo:dict];
            return;
        }

        if ([iqid isEqualToString:@"UserLeave"]) {
            [IMReasonableDao setNotinRoom:iq.from.bare];
            [self.roomDelegate deleteRoom:2];
        }
        if ([iqid isEqualToString:@"AdminGetOut"]) {
            [IMReasonableDao deleteRoomUser:iq.from.bare userjidstr:deleteUser];
            [self.roomDelegate deleteRoom:1];
        }

        //销毁群
        if ([iqid isEqualToString:@"IOSD"]) {

            [IMReasonableDao setNotinRoom:iq.from.bare];
            [self.roomDelegate deleteRoom:0];
        }

        if ([@"vCard" isEqualToString:query.name]) {

            NSArray* items = [query children];
            for (NSXMLElement* item in items) {
                for (NSXMLElement* photo in [item children]) {
                    if ([@"BINVAL" isEqualToString:photo.name]) {
                        NSString* tempimag = [photo stringValue];
                        NSData* dataFromString = [[NSData alloc] initWithBase64EncodedString:tempimag options:0];

                        NSString* fromjidstrname = [[iq.fromStr componentsSeparatedByString:@"@"] objectAtIndex:0];
                        NSString* fromjidstr = [[iq.fromStr componentsSeparatedByString:@"/"] objectAtIndex:0];
                        [Tool saveFileToDoc:fromjidstrname fileData:dataFromString];
                        if ([fromjidstr isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:XMPPREASONABLEJID]]) {
                            [[NSUserDefaults standardUserDefaults] setObject:[fromjidstrname stringByAppendingString:@".png"] forKey:XMPPMYFACE];
                        }
                        else {
                            [IMReasonableDao updateUserfaceurl:fromjidstr faceurl:fromjidstrname];
                        }
                    }
                }
            }
        }

    } //end ResultIQ

    if (iq.isGetIQ) {

        //解析iq 是ping类型则给openfier 响应一个IQ

        NSXMLElement* query = iq.childElement;
        if ([@"ping" isEqualToString:query.name]) {
            //服务器会在给定的时间内向客户端发送ping包（用来确认客户端用户是否在线）,当第二次发送bing包时，如果客户端无响应则会T用户下线
            NSXMLElement* ping = [NSXMLElement elementWithName:@"ping" xmlns:@"jabber:client"];
            NSXMLElement* iq = [NSXMLElement elementWithName:@"iq"];
            XMPPJID* myJID = self.xmppStream.myJID;
            [iq addAttributeWithName:@"from" stringValue:myJID.description];
            [iq addAttributeWithName:@"to" stringValue:myJID.domain];
            [iq addAttributeWithName:@"type" stringValue:@"get"];
            [iq addChild:ping];
            //发送的iq可以不做任何的设置
            NSLog(@"%@", iq);
            [self.xmppStream sendElement:iq];
        }
    }
}

- (void)xmppStream:(XMPPStream*)sender didReceiveMessage:(XMPPMessage*)message
{

    //NSLog(@"%@",message.fromStr);

    NSLog(@"收到好友消息***************************************%@", message);

    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        [self doMessage:message];
    });
}

- (void)doMessage:(XMPPMessage*)message
{
    NSXMLElement* request = [message elementForName:@"request"];
    if ([message.fromStr isEqualToString:message.toStr]) {
        return;
    }

    //收到聊天室的邀请
    NSXMLElement* x = [message elementForName:@"x" xmlns:XMPPMUCUserNamespace];
    NSXMLElement* invite = [x elementForName:@"invite"];
    NSXMLElement* directInvite = [message elementForName:@"x" xmlns:@"jabber:x:conference"];
    if (invite || directInvite) {

        [self loginChatRoom:message.fromStr];
        [self GetRoomUserList:message.fromStr]; //其实这个操作不是很必要

        NSString* faceurl = [self GetRoomUrl:message.fromStr];
        NSXMLElement* reason = [invite elementForName:@"reason"];
        [IMReasonableDao creatChatRoom:message.fromStr nick:@"您" subject:[reason stringValue] faceurl:faceurl isMeCreat:@"0"];
        [self.chatHelerpDelegate userStatusChange:nil];
        return;
    }

    //处理特殊账号
    /***NSXMLElement *at=[message elementForName:@"AT"];//判断是否有该节点 拥有该节点为服务器特殊账号
    if (at) {
        [self tipServerMessage:message isFwd:false accountType:[at stringValue]];
    }***/

    //处理群的消息
    if ([message.type isEqualToString:@"groupchat"]) {
        [self dealwithGroupMessage:message];
        return;
    }

    //处理单对单的消息
    if (request) {
        if ([request.xmlns isEqualToString:@"urn:xmpp:receipts"]) //收到需要回执的消息
        {
            //组装消息回执
            NSString* msgid = [message attributeStringValueForName:@"id"];
            XMPPMessage* msg = [XMPPMessage messageWithType:[message attributeStringValueForName:@"type"] to:message.from elementID:msgid];
            NSLog(@"msg:%@", msg);
            NSXMLElement* recieved = [NSXMLElement elementWithName:@"received" xmlns:@"urn:xmpp:receipts"];
            [recieved addAttributeWithName:@"id" stringValue:msgid];
            [msg addChild:recieved];
            [self.xmppStream sendElement:msg];

            NSArray* items = [message children];

            if ([message isChatMessageWithBody] || [message.subject isEqualToString:@"img"]) {
                [self TipMessage:message isFwd:false];
                return;
            }

            for (NSXMLElement* item in items) {
                if ([item.name isEqualToString:@"sent"]) {
                    DDXMLNode* fwnode = item.nextNode;
                    DDXMLNode* mes = fwnode.nextNode;
                    XMPPMessage* tempmsg = [XMPPMessage messageFromElement:(NSXMLElement*)mes];
                    [self TipMessage:tempmsg isFwd:true];
                }
            }
        }
    }
    else {
        NSXMLElement* received = [message elementForName:@"received"]; //自己的发送的消息送达
        if (received) {
            NSString* msgID = [received attributeStringValueForName:@"id"];
            [IMReasonableDao updateMsgAccpect:msgID];
            [self.friendreceivemsgDelegate friendreceivemsg];
        }
    }
}

- (NSString*)GetRoomUrl:(NSString*)roomjidstr
{

    NSURL* url = [NSURL URLWithString:[Tool Append:IMReasonableAPP witnstring:@"GetRoomFaceurl"]];
    NSString* Apikey = IMReasonableAPPKey;
    NSDictionary* sendsms = [[NSDictionary alloc] initWithObjectsAndKeys:Apikey, @"apikey", roomjidstr, @"roomjidstr", nil];
    NSDictionary* sendsmsD = [[NSDictionary alloc] initWithObjectsAndKeys:sendsms, @"geturl", nil];
    if ([NSJSONSerialization isValidJSONObject:sendsmsD]) {
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:sendsmsD options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableData* tempJsonData = [NSMutableData dataWithData:jsonData];
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
        [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:tempJsonData];
        [request startSynchronous];
        error = [request error];
        if (error == nil) {
            NSData* responsedata = [request responseData];
            NSDictionary* dict = [Tool jsontodate:responsedata];
            NSDictionary* code = [dict objectForKey:@"GetRoomFaceurlResult"];
            NSString* state = [code objectForKey:@"state"];
            if ([state isEqualToString:@"1"]) {
                NSString* faceurl = [code objectForKey:@"faceurl"];
                return faceurl;
                // [IMReasonableDao updateRoomFaceurl:faceurl roomjidstr:roomjidstr];
            }
        }
    }

    return @"";

    //[self.chatHelerpDelegate userStatusChange:nil];
}

//处理聊天类的消息
- (void)dealwithGroupMessage:(XMPPMessage*)message
{
    // NSString * fromjidstr=message.from.bare; //不这样写的原因是 这个操作效率很低 可能是底层没有实现的很完美，用字符串截取可以节省时间
    NSString* fromjidstr = [[message.fromStr componentsSeparatedByString:@"/"] objectAtIndex:0];
    NSString* tojibstr = [[message.toStr componentsSeparatedByString:@"/"] objectAtIndex:0];
    NSString* type; //=message.subject;

    NSString* time = nil;
    NSXMLElement* delay = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
    NSString* stamp = [delay attributeStringValueForName:@"stamp"];
    //这写法是为了避免更多的时间计算 在需要哪一类的时间的时候就计算哪一类
    if (stamp) {
        time = [Tool getLocalDateFormateUTCDate:stamp];
    }
    else {
        if (message.time) {
            time = [Tool GetTimeFromstring:[message.time substringToIndex:message.time.length - 3]];
        }
        else {
            time = [Tool getTime];
        }
    }

    NSArray* temptype = [message.subject componentsSeparatedByString:@"|"];

    type = [temptype objectAtIndex:0];

    NSString* msgID = [message attributeStringValueForName:@"id"];
    ///////////////////////////////////////////////处理逻辑
    //收到消息
    //1. 向messagee表添加一条消息
    //2. 激活用户 不需要关心失败还是成功
    //3.添加成功 更新user表的msgID和unread+1
    //4.播放音乐提醒其他页面收到消息

    if (!type || !message.body) {
        return;
    }
    NSString* content = message.body;
    NSString* voicelenth = @"0";

    //    if (![type isEqualToString:@"chat"]) {
    //        type=message.subject;
    //
    //    }

    if ([type isEqualToString:@"voice"]) {
        if (temptype.count > 1) {
            voicelenth = [temptype objectAtIndex:1];
        }
        else {
            voicelenth = 0;
        }

        NSData* filedata = [Tool Base64StringtoNSData:message.body];

        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a = [dat timeIntervalSince1970] * 1000;
        NSString* timeString = [NSString stringWithFormat:@"%f", a];
        NSString* voicename = [NSString stringWithFormat:@"%@.caf", timeString];
        NSString* voicepath = [Tool getVoicePath:voicename];
        [Tool saveFile:voicepath fileData:filedata];
        content = voicename;
    }

    if (!msgID) {

        msgID = [Tool GetOnlyString];
    }

    BOOL flag = false;

    if (message.body) {

        NSString* gr;
        if ([message.from.resource rangeOfString:@"@"].location != NSNotFound) {
            gr = message.from.resource;
        }
        else {
            gr = [NSString stringWithFormat:@"%@%@", message.from.resource, XMPPSERVER2];
        }

        flag = [IMReasonableDao SaveGroupMessage2:msgID fromjidstr:fromjidstr tojidstr:tojibstr body:content type:type date:time groupfrom:gr voicelenth:voicelenth];
        if (flag) {

            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"jidstr==%@", message.from.bare]; //用于过滤
            NSArray* room = [NSMutableArray arrayWithArray:[allRoom filteredArrayUsingPredicate:predicate]];

            if (room.count > 0) {
                IMChatListModle* temp = [room objectAtIndex:0];
                if ([temp.isNeedTip isEqualToString:@"1"]) {

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playSound) object:nil];
                        [self performSelector:@selector(playSound) withObject:nil afterDelay:0.5f];
                    });
                }
            }

            [IMReasonableDao updateChatRoom:fromjidstr msgID:msgID];
        }
    }

    //下面这段代码除了代理其他可有可无
    IMMessage* tempmeseage = [[IMMessage alloc] init];
    tempmeseage.ID = msgID;
    tempmeseage.from = fromjidstr;
    tempmeseage.to = tojibstr;
    tempmeseage.body = message.body;
    tempmeseage.type = type;
    tempmeseage.date = time;
    tempmeseage.groupfrom = [NSString stringWithFormat:@"%@@%@", message.from.resource, XMPPSERVER];

    if (flag) {
        if ([self.chatHelerpDelegate respondsToSelector:@selector(receiveNewMessage:isFwd:)]) {
            [self.chatHelerpDelegate receiveNewMessage:tempmeseage isFwd:true];
        }
    }
}

- (void)localNotification:(XMPPMessage*)msg
{

    if (!([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)) {

        NSString* displayname = [IMReasonableDao GetUserLocalNameByjidstr:msg.from.bare]; // [self GetUserName:msg.from.bare];
        if (!displayname && [displayname isEqualToString:@""]) {
            displayname = [[msg.from.bare componentsSeparatedByString:@"@"] objectAtIndex:0];
        }
        NSString* body = msg.body;
        //NSString * type=msg.type;

        if ([msg.subject isEqualToString:IMG]) {
            body = @"[img]";
        }
        else if ([msg.subject isEqualToString:VOICE] || [msg.subject isEqualToString:GROUP_VOICE] || [msg.subject isEqualToString:GROUP_VOICE2]) {

            body = @"[voice]";
        }
        else if ([msg.subject isEqualToString:EMAIL]) {

            body = @"email";
        }
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Ok";
        localNotification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"lbNotio", nil), displayname, body];

        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        [self setapplicationIconBadgeNumber];
    }
}

- (void)setapplicationIconBadgeNumber
{
    NSInteger icount = [IMReasonableDao getUnreadMessageCount];
    [UIApplication sharedApplication].applicationIconBadgeNumber = icount > 99 ? 99 : icount;
}

- (void)tipServerMessage:(XMPPMessage*)message isFwd:(BOOL)isfwd accountType:(NSString*)at
{
    NSString* fromjidstr = message.from.bare;
    NSString* tojibstr = message.to.bare;
    NSString* type = message.type;
    NSString* time = [Tool GetTimeFromstring:[message.time substringToIndex:message.time.length - 3]];
    NSString* msgID = [message attributeStringValueForName:@"id"];

    ///////////////////////////////////////////////处理逻辑
    //收到消息
    //1. 向messagee表添加一条消息
    //2. 激活用户 不需要关心失败还是成功
    //3.添加成功 更新user表的msgID和unread+1
    //4.播放音乐提醒其他页面收到消息
    NSString* content = message.body;
    NSString* voicelenth = message.voicelenth;

    if (![message.subject isEqualToString:@"chat"]) {
        type = message.subject;
    }
    //取消语音相关的处理
    //    if ([message.subject isEqualToString:@"voice"]) {
    //        NSData * filedata=[Tool Base64StringtoNSData:message.body];
    //
    //        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    //        NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    //        NSString *timeString = [NSString stringWithFormat:@"%f", a];
    //        NSString * voicename=[NSString stringWithFormat:@"%@.caf",timeString];
    //        NSString * voicepath=[Tool getVoicePath:voicename];
    //        [Tool saveFile:voicepath fileData:filedata];
    //        content=voicename;
    //
    //    }

    // dispatch_async(dispatch_get_global_queue(0, 0), ^{

    BOOL flag = [IMReasonableDao saveMessage:fromjidstr to:tojibstr body:content type:type date:time voicelenth:voicelenth msgID:msgID];
    if (flag) {
        XMPPJID* jid = [XMPPJID jidWithString:message.fromStr];
        [self acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
        [self queryOneRoster:jid.bare];
    }

    NSString* name = @"";
    if ([at isEqualToString:SPREADMAILACCOUNTTYPE]) {
        name = NSLocalizedString(@"lbrspreadmail", @"RSpreadMail Notification");
    }

    [IMReasonableDao updateUseractive:fromjidstr tojidstr:message.to.bare msgID:msgID accounttype:at localname:name];

    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playSound) object:nil];
        [self performSelector:@selector(playSound) withObject:nil afterDelay:0.5f];
    });
    IMMessage* tempmeseage = [[IMMessage alloc] init];
    tempmeseage.ID = msgID;
    tempmeseage.from = fromjidstr;
    tempmeseage.to = tojibstr;
    tempmeseage.body = message.body;
    tempmeseage.type = type;
    tempmeseage.date = time;

    [self.chatHelerpDelegate receiveNewMessage:tempmeseage isFwd:isfwd];
}

- (void)TipMessage:(XMPPMessage*)message isFwd:(BOOL)isfwd
{

    NSLog(@"TipMessage:%@", message);
    NSString* fromjidstr = message.from.bare;
    NSString* tojibstr = message.to.bare;
    NSString* type = message.type;
    NSString* time = [Tool GetTimeFromstring:[message.time substringToIndex:message.time.length - 3]];
    NSString* msgID = [message attributeStringValueForName:@"id"];

    ///////////////////////////////////////////////处理逻辑
    //收到消息
    //1. 向messagee表添加一条消息
    //2. 激活用户 不需要关心失败还是成功
    //3.添加成功 更新user表的msgID和unread+1
    //4.播放音乐提醒其他页面收到消息
    NSString* content = message.body;
    NSString* voicelenth = message.voicelenth;

    if([message.subject isEqualToString:EMAIL]){
        
        time = [Tool GetDate:@"yyyy-MM-dd HH:mm:ss"];
        
    }
    
    if (![message.subject isEqualToString:@"chat"]) {
        type = message.subject;
        voicelenth=@"0";
    }

    if ([message.subject isEqualToString:@"voice"]) {

        NSLog(@"voice%@", message.body);

        NSData* filedata = [Tool Base64StringtoNSData:message.body];

        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a = [dat timeIntervalSince1970] * 1000;
        NSString* timeString = [NSString stringWithFormat:@"%f", a];
        NSString* voicename = [NSString stringWithFormat:@"%@.caf", timeString];
        NSString* voicepath = [Tool getVoicePath:voicename];
        [Tool saveFile:voicepath fileData:filedata];
        content = voicename;
    }

    // dispatch_async(dispatch_get_global_queue(0, 0), ^{

    BOOL flag = [IMReasonableDao saveMessage:fromjidstr to:tojibstr body:content type:type date:time voicelenth:voicelenth msgID:msgID];
    if (flag) {
        XMPPJID* jid = [XMPPJID jidWithString:message.fromStr];
        [self acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
        [self queryOneRoster:jid.bare];
    }
    [IMReasonableDao updateUseractive:fromjidstr tojidstr:message.to.bare msgID:msgID accounttype:@"0" localname:@""];

    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playSound) object:nil];
        [self performSelector:@selector(playSound) withObject:nil afterDelay:0.5f];
    });
    IMMessage* tempmeseage = [[IMMessage alloc] init];
    tempmeseage.ID = msgID;
    tempmeseage.from = fromjidstr;
    tempmeseage.to = tojibstr;
    tempmeseage.body = message.body;
    tempmeseage.type = type;
    tempmeseage.date = time;

    [self.chatHelerpDelegate receiveNewMessage:tempmeseage isFwd:isfwd];

    // });
}
- (void)playSound

{
    //    SystemSoundID shake_sound_male_id = 0;
    //    NSString *thesoundFilePath = [[NSBundle mainBundle] pathForResource:@"ReceivedMessage" ofType:@"caf"]; //音乐文件路径
    //    CFURLRef thesoundURL = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:thesoundFilePath]);
    //    AudioServicesCreateSystemSoundID(thesoundURL, &shake_sound_male_id);
    //    AudioServicesPlaySystemSound(shake_sound_male_id);
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    //系统声音和震动
    AudioServicesPlaySystemSound(1004); //更换播放系统的声音
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)xmppStream:(XMPPStream*)sender didSendMessage:(XMPPMessage*)message
{
    //    NSLog(@"消息发送出去咯");
    //    NSString * tojibstr=message.to.bare;

    IMMessage* tempmeseage = [[IMMessage alloc] init];
    tempmeseage.ID = [message attributeStringValueForName:@"id"];

    [IMReasonableDao updatesendstate:tempmeseage.ID isNeedSend:@"1"];

    NSXMLElement* received = [message elementForName:@"received"];
    if (!received) {
        [self.chatHelerpDelegate isSuccSendMessage:tempmeseage issuc:true];
    }
}
- (void)xmppStream:(XMPPStream*)sender didNotSendMessage:(XMPPMessage*)message
{
    NSLog(@"未把消息发送出去");
    //    NSString * fromjidstr=[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
    //    NSString * tojibstr=message.to.bare;
    //    IMMessage * tempmeseage=[[IMMessage alloc] init];
    //    tempmeseage.from=fromjidstr;
    //    tempmeseage.to=tojibstr;
    //    tempmeseage.body=message.body;
    //    tempmeseage.type=message.type;
    //    tempmeseage.date=[Tool GetDate:@"yyyy-MM-dd HH:mm:ss"];

    IMMessage* tempmeseage = [[IMMessage alloc] init];
    tempmeseage.ID = [message attributeStringValueForName:@"id"];

    [IMReasonableDao updatesendstate:tempmeseage.ID isNeedSend:@"0"];

    NSXMLElement* received = [message elementForName:@"received"];

    if (!received) {
        [self.chatHelerpDelegate isSuccSendMessage:tempmeseage issuc:false];
    }
}

- (void)xmppStream:(XMPPStream*)sender didReceivePresence:(XMPPPresence*)presence
{

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self doPresence:presence];
    });
}

- (void)doPresence:(XMPPPresence*)presence
{

    //NSLog(@"didReceivePresence 收到状态消息");
    //    NSLog(@"%@----------------------------%@-------------------------------%@",presence,presence.fromStr,presence.type);

    // NSAssert(![presence.fromStr isEqualToString: @"8613428680545@talk-king.net"], @"b 是 零");

    if ([presence.type isEqualToString:@"error"]) {
        NSXMLElement* error = [presence elementForName:@"error"];
        NSString* code = [error attributeStringValueForName:@"code"];
        NSString* auth = [error attributeStringValueForName:@"type"];
        if ([auth isEqualToString:@"auth"] && [code isEqualToString:@"407"]) {
            [IMReasonableDao setNotinRoom:presence.from.bare];
            return;
        }
    }

    NSString* presenceType = [NSString stringWithFormat:@"%@", [presence type]];
    if ([presenceType isEqualToString:@"subscribe"]) {

        XMPPJID* jid = [XMPPJID jidWithString:presence.fromStr];
        [self acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
        return;
    }

    //处理群的踢人 消群操作
    NSXMLElement* status = [presence elementForName:@"status"];
    NSXMLElement* x = [presence elementForName:@"x" xmlns:XMPPMUCUserNamespace];

    if (status) {
        NSInteger code = [status attributeIntegerValueForName:@"code" withDefaultValue:0];
        NSString* userjidstr = [NSString stringWithFormat:@"%@@%@", presence.from.resource, XMPPSERVER];
        [self.roomDelegate deleteRoomUser:code userjidstr:userjidstr];
    }

    NSXMLElement* destroy = [x elementForName:@"destroy"];
    if (destroy) {
        [IMReasonableDao setNotinRoom:presence.from.bare];
        return;
    }

    NSXMLElement* item = [x elementForName:@"item"];
    if (item) {
        [self deleteuser:item roomjidstr:presence];
    }

    if (x) { //下面是处理个人状态信息的类
        return;
    }

    if (![[[NSUserDefaults standardUserDefaults] objectForKey:XMPPREASONABLEJID] isEqualToString:presence.from.bare]) { //屏蔽掉自己的状态

        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            if ([presence.type isEqualToString:@"available"]) {
                [IMReasonableDao setUserDevice:presence.from.bare device:presence.from.resource state:presence.type isneedtime:YES];
            }
            else {
                [IMReasonableDao setUserDevice:presence.from.bare device:@" " state:presence.type isneedtime:NO];
            }

            //dispatch_async(dispatch_get_main_queue(), ^{
            [self.chatHelerpDelegate userStatusChange:presence];
            // });

        });

        NSXMLElement* photochange = [presence elementForName:@"x" xmlns:@"vcard-temp:x:update"];
        if (photochange) {
            [self queryOneRoster:presence.fromStr];
            return;
        }
    }
    else { //自己给自己的状态

        if ([presence.type isEqualToString:@"unavailable"]) {
            [self connect];
        }

        NSString* photo;
        NSString* hash;
        NSString* jidstr = presence.from.bare;
        NSXMLElement* item = [presence elementForName:@"x"];

        if ([item.xmlns isEqualToString:@"jabber:x:avatar"]) {
            photo = [[presence elementForName:@"photo"] stringValue];
        }
        if ([item.xmlns isEqualToString:@"vcard-temp:x:update"]) {
            hash = [[presence elementForName:@"photo"] stringValue];
        }
        BOOL flag = [IMReasonableDao isNeedupdateUserPhoto:jidstr photo:photo hash:hash];
        if (flag) {
            [self queryOneRoster:jidstr];
        }
    }
}

- (void)deleteuser:(NSXMLElement*)item roomjidstr:(XMPPPresence*)presence
{
    NSString* userjidstr = [item attributeStringValueForName:@"nick"];
    NSString* role = [item attributeStringValueForName:@"affiliation"];
    NSString* userbare = [NSString stringWithFormat:@"%@@%@", userjidstr, XMPPSERVER];
    NSString* myjidstr = self.xmppStream.myJID.bare;
    if ([role isEqualToString:@"none"]) {
        NSString* jidstr = presence.from.bare;

        if ([userbare isEqualToString:myjidstr]) {
            [IMReasonableDao setNotinRoom:presence.from.bare];
        }

        [IMReasonableDao deleteRoomUser:jidstr userjidstr:userbare];
        [self.roomDelegate deleteRoom:1];
    }

    if ([role isEqualToString:@"owner"]) {
        NSString* jidstr = presence.from.bare;
        if ([userbare isEqualToString:myjidstr]) {
            [IMReasonableDao setRoomisMy:jidstr];
        }
    }
}

- (void)xmppStream:(XMPPStream*)sender didReceiveError:(id)error
{
    NSLog(@"didReceiveError 收消息错误");
    // DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

#pragma mark -注册的结果返回注册成功或不成功
- (void)xmppStreamDidRegister:(XMPPStream*)sender
{
    NSLog(@"注册成功");

    [self.authloginDelegate isSuccReg:true];
}
//注册失败
- (void)xmppStream:(XMPPStream*)sender didNotRegister:(NSXMLElement*)error
{

    NSLog(@"注册失败");
    [self.authloginDelegate isSuccReg:false];
    // NSLog(@"%@",[[error elementForName:@"error"] stringValue]);
}

#pragma mark -重连代理

- (void)xmppReconnect:(XMPPReconnect*)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags
{

    // DLog(@"didDetectAccidentalDisconnect : \n %u ", connectionFlags);
}

- (BOOL)xmppReconnect:(XMPPReconnect*)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags
{

    // DLog(@"shouldAttemptAutoReconnect : \n %u ", connectionFlags);

    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#pragma mark XMPPRosterDelegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
//{
//    NSLog(@"收到添加好友请求");
//    //        //收到好友消息不交给用户处理，直接添加为好友
//    //    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
//    //    XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
//    //    [xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
//
//
//
//}
//
//- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
//{
//    NSLog(@"收到好友请求");
//    //    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
//    //    XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
//    //    [xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
//}

#pragma mark -私有化方法用来处理xmpp的一些事情
- (void)XMPPAddFriendSubscribe:(NSString*)name
{
    NSLog(@"添加好友-%@", name);
    XMPPJID* jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", name, XMPPSERVER]];
    [self acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    // [self subscribePresenceToUser:jid];
}
- (void)XMPPAddFriendSubscribe2:(NSString*)jidstr
{
    NSLog(@"添加好友-%@", jidstr);
    XMPPJID* jid = [XMPPJID jidWithString:jidstr];
    // [self acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    [self addUser:jid withNickname:nil];
    // [self subscribePresenceToUser:jid];
}
//添加好友
- (void)addUser:(XMPPJID*)jid withNickname:(NSString*)optionalName
{
    [self addUser:jid withNickname:optionalName groups:nil subscribeToPresence:YES];
}
- (void)addUser:(XMPPJID*)jid withNickname:(NSString*)optionalName groups:(NSArray*)groups subscribeToPresence:(BOOL)subscribe
{

    NSLog(@"正在处理添加好友");

    if (jid == nil)
        return;

    XMPPJID* myJID = xmppStream.myJID;

    if ([myJID isEqualToJID:jid options:XMPPJIDCompareBare]) {
        return;
    }

    // Add the buddy to our roster
    //
    // <iq type="set">
    //   <query xmlns="jabber:iq:roster">
    //     <item jid="bareJID" name="optionalName">
    //      <group>family</group>
    //     </item>
    //   </query>
    // </iq>

    NSXMLElement* item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"jid" stringValue:[jid bare]];

    if (optionalName) {
        [item addAttributeWithName:@"name" stringValue:optionalName];
    }

    for (NSString* group in groups) {
        NSXMLElement* groupElement = [NSXMLElement elementWithName:@"group"];
        [groupElement setStringValue:group];
        [item addChild:groupElement];
    }

    NSXMLElement* query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    [query addChild:item];

    NSXMLElement* iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addChild:query];

    NSLog(@"%@", iq);
    [xmppStream sendElement:iq];

    // [Tool alert:@"添加对方为好友"];

    if (subscribe) {
        [self subscribePresenceToUser:jid];
    }
}

- (void)subscribePresenceToUser:(XMPPJID*)jid
{

    if (jid == nil)
        return;
    XMPPJID* myJID = xmppStream.myJID;

    if ([myJID isEqualToJID:jid options:XMPPJIDCompareBare]) {
        return;
    }
    //[self acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    XMPPPresence* presence = [XMPPPresence presenceWithType:@"subscribe" to:[jid bareJID]];
    [xmppStream sendElement:presence];
}

- (void)acceptPresenceSubscriptionRequestFrom:(XMPPJID*)jid andAddToRoster:(BOOL)flag
{
    // This is a public method, so it may be invoked on any thread/queue.

    // Send presence response
    //
    // <presence to="bareJID" type="subscribed"/>

    XMPPPresence* presence = [XMPPPresence presenceWithType:@"subscribed" to:[jid bareJID]];
    [xmppStream sendElement:presence];

    if (flag) {
        [self addUser:jid withNickname:nil];
    }
}

#pragma mark -查询自己的好友列表
- (void)queryRoster
{
    NSXMLElement* query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement* iq = [NSXMLElement elementWithName:@"iq"];
    XMPPJID* myJID = self.xmppStream.myJID;
    [iq addAttributeWithName:@"from" stringValue:myJID.description];
    [iq addAttributeWithName:@"to" stringValue:myJID.domain];
    [iq addAttributeWithName:@"id" stringValue:@"123456"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:query];
    [self.xmppStream sendElement:iq];
}

- (void)queryOneRoster:(NSString*)jibstr
{
    XMPPIQ* iq = [XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"id" stringValue:jibstr];
    [iq addAttributeWithName:@"to" stringValue:jibstr];
    NSXMLElement* vElement = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    [iq addChild:vElement];
    [xmppStream sendElement:iq];
}

- (void)SetUserPhoto:(NSString*)jidstr photo:(NSString*)pho
{
    //    <iq from='juliet@capulet.com'
    //    type='set'
    //    id='vc1'>
    //    <vCard xmlns='vcard-temp'>
    //    <BDAY>1476-06-09</BDAY>
    //    <ADR>
    //    <CTRY>Italy</CTRY>
    //    <LOCALITY>Verona</LOCALITY>
    //    <HOME/>
    //    </ADR>
    //    <NICKNAME/>
    //    <N><GIVEN>Juliet</GIVEN><FAMILY>Capulet</FAMILY></N>
    //    <EMAIL>jcapulet@shakespeare.lit</EMAIL>
    //    <PHOTO>
    //    <TYPE>image/jpeg</TYPE>
    //    <BINVAL>
    //    Base64-encoded-avatar-file-here!
    //    </BINVAL>
    //    </PHOTO>
    //    </vCard>
    //    </iq>

    XMPPIQ* iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"from" stringValue:jidstr];
    [iq addAttributeWithName:@"id" stringValue:@"vc1"];
    NSXMLElement* vElement = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    NSXMLElement* photoXML = [NSXMLElement elementWithName:@"PHOTO"];
    NSXMLElement* typeXML = [NSXMLElement elementWithName:@"TYPE" stringValue:@"image/jpeg"];
    NSXMLElement* binvalXML = [NSXMLElement elementWithName:@"BINVAL" stringValue:pho];
    [photoXML addChild:typeXML];
    [photoXML addChild:binvalXML];
    [vElement addChild:photoXML];
    [iq addChild:vElement];
    NSLog(@"%@", iq);
    [xmppStream sendElement:iq];
}
- (void)querySetMyCarbons:(NSString*)jibstr
{
    XMPPIQ* iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"from" stringValue:jibstr];
    [iq addAttributeWithName:@"id" stringValue:@"IMenable"];
    NSXMLElement* vElement = [NSXMLElement elementWithName:@"enable" xmlns:@"urn:xmpp:carbons:2"];
    [iq addChild:vElement];
    [xmppStream sendElement:iq];
}

- (void)loginChatRoom:(NSString*)roomjidstr
{

    XMPPPresence* presence = [XMPPPresence presence]; // type="available" is implicit
    NSString* myJID = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
    NSString* jidstr = [[myJID componentsSeparatedByString:@"@"] objectAtIndex:0];
    NSString* jidstrwithnick = [NSString stringWithFormat:@"%@/%@", roomjidstr, jidstr];
    [presence addAttributeWithName:@"from" stringValue:myJID];
    [presence addAttributeWithName:@"to" stringValue:jidstrwithnick];
    NSXMLElement* x = [NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];
    [presence addChild:x];
    [[self xmppStream] sendElement:presence];
}

- (void)SetOneLeave:(NSString*)Roomjidstr leaveuser:(NSString*)userjidstr iqid:(NSString*)iqid
{
    //    <iq from='crone1@shakespeare.lit/desktop'
    //    id='member2'
    //    to='darkcave@chat.shakespeare.lit'
    //    type='set'>
    //    <query xmlns='http://jabber.org/protocol/muc#admin'>
    //    <item affiliation='none'
    //    jid='hag66@shakespeare.lit'/>
    //    </query>
    //    </iq>

    deleteUser = userjidstr;

    XMPPJID* myJID = self.xmppStream.myJID;

    XMPPIQ* iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"from" stringValue:myJID.full];
    [iq addAttributeWithName:@"id" stringValue:iqid]; //@"UserLeave"
    [iq addAttributeWithName:@"to" stringValue:Roomjidstr];
    NSXMLElement* query = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCAdminNamespace];
    NSXMLElement* item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"affiliation" stringValue:@"none"];
    [item addAttributeWithName:@"jid" stringValue:userjidstr];

    [query addChild:item];
    [iq addChild:query];

    NSLog(@"%@", iq);
    [xmppStream sendElement:iq];
}

//获取群的成员
- (void)GetRoomUserList:(NSString*)roomjidstr
{
    //    <iq from='crone1@shakespeare.lit/desktop'
    //    id='member3'
    //    to='darkcave@chat.shakespeare.lit'
    //    type='get'>
    //    <query xmlns='http://jabber.org/protocol/muc#admin'>
    //    <item affiliation='member'/>
    //    </query>
    //    </iq>

    //////////////////////////////////////////////

    //    <iq from='crone1@shakespeare.lit/desktop'
    //    id='member3'
    //    to='darkcave@chat.shakespeare.lit'
    //    type='get'>
    //    <query xmlns='http://jabber.org/protocol/muc#admin'>
    //    <item affiliation='member'/>
    //    </query>
    //    </iq>

    XMPPJID* myJID = self.xmppStream.myJID;
    XMPPIQ* iq = [XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"from" stringValue:myJID.full];
    [iq addAttributeWithName:@"id" stringValue:@"IOSROOMLIST"];
    [iq addAttributeWithName:@"to" stringValue:roomjidstr];
    NSXMLElement* query = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCAdminNamespace];
    NSXMLElement* item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"affiliation" stringValue:@"member"];
    [query addChild:item];
    [iq addChild:query];

    XMPPIQ* iq2 = [XMPPIQ iqWithType:@"get"];
    [iq2 addAttributeWithName:@"from" stringValue:myJID.full];
    [iq2 addAttributeWithName:@"id" stringValue:@"IOSROOMLIST"];
    [iq2 addAttributeWithName:@"to" stringValue:roomjidstr];
    NSXMLElement* query2 = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCAdminNamespace];
    NSXMLElement* item2 = [NSXMLElement elementWithName:@"item"];
    [item2 addAttributeWithName:@"affiliation" stringValue:@"owner"];
    [query2 addChild:item2];
    [iq2 addChild:query2];

    NSLog(@"%@", iq);
    NSLog(@"%@", iq2);
    [xmppStream sendElement:iq2];
    [xmppStream sendElement:iq];
}

- (void)SendDevicetoken
{

    //    <iq type=set to=push@reason-sz.no-ip.org from=8618319994334@>
    //    <register xmlns=http://talk-king.net/extensions/push provider=apns >
    //    57ceb3cb3c793ff9a0528c3e403b3efcc632f6c215d346b7959a967ecf3f1fba
    //    </register>
    //    </iq>

    NSString* token = [[NSUserDefaults standardUserDefaults] stringForKey:@"DeviceToken"];
    XMPPJID* myJID = self.xmppStream.myJID;
    XMPPIQ* iq = [XMPPIQ iqWithType:@"set"];
    NSString* to = [NSString stringWithFormat:@"%@%@", @"push", XMPPSERVER2];
    [iq addAttributeWithName:@"from" stringValue:myJID.full];
    [iq addAttributeWithName:@"to" stringValue:to];

    NSXMLElement* registers = [NSXMLElement elementWithName:@"register" xmlns:@"http://talk-king.net/extensions/push"];
    [registers addAttributeWithName:@"provider" stringValue:@"apns"];

    [registers setStringValue:token];
    [iq addChild:registers];

    NSLog(@"%@", iq);
    [xmppStream sendElement:iq];
}

//把自己新建的房间销毁掉
- (void)DestroyRoom:(NSString*)roomjidstr
{

    //    <iq from='crone1@shakespeare.lit/desktop'
    //    id='begone'
    //    to='heath@chat.shakespeare.lit'
    //    type='set'>
    //    <query xmlns='http://jabber.org/protocol/muc#owner'>
    //    <destroy />
    //    </destroy>
    //    </query>
    //    </iq>

    XMPPJID* myJID = self.xmppStream.myJID;
    XMPPIQ* iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"from" stringValue:myJID.full];
    [iq addAttributeWithName:@"id" stringValue:@"IOSD"];
    [iq addAttributeWithName:@"to" stringValue:roomjidstr];
    NSXMLElement* query = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCOwnerNamespace];
    NSXMLElement* destroy = [NSXMLElement elementWithName:@"destroy"];
    [query addChild:destroy];
    [iq addChild:query];
    NSLog(@"%@", iq);
    [xmppStream sendElement:iq];
}

- (void)SetMyPushName:(NSString*)Name
{
    //    <iq from="8618603026485@reason-sz.no-ip.org" id="uwrO8-11" type="set">
    //    <pushName xmlns="talkKing:pushName">谢佳桦Kevin</pushName>
    //    </iq>

    XMPPJID* myJID = self.xmppStream.myJID;
    XMPPIQ* iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"from" stringValue:myJID.full];
    [iq addAttributeWithName:@"id" stringValue:@"V"];
    NSXMLElement* pushName = [NSXMLElement elementWithName:@"pushName" xmlns:@"talkKing:pushName"];
    [pushName setStringValue:Name];
    [iq addChild:pushName];
    NSLog(@"%@", iq);
    [xmppStream sendElement:iq];
}

- (void)checkUser:(NSMutableArray*)userarr
{
    //    <iq id="pebif-310" type="get">
    //    <query xmlns="talkKing:roster">
    //    <item jid="8618603026485@reason-sz.no-ip.org" />
    //    <item jid="8618603026485@reason-sz.no-ip.org" />
    //    <item jid="8618603026483-1431936894@muc.reason-sz.no-ip.org" />
    //    <item jid="8615012538875@reason-sz.no-ip.org" />
    //    <item jid="8685260187589@reason-sz.no-ip.org" />
    //    <item jid="8618074845030@reason-sz.no-ip.org" />
    //    <item jid="8615078366712@reason-sz.no-ip.org" />
    //    <item jid="8615277397628@reason-sz.no-ip.org" />
    //    </query>
    //    </iq>

    XMPPIQ* iq = [XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"ISUSER"];
    NSXMLElement* query = [NSXMLElement elementWithName:@"query" xmlns:@"talkKing:roster"];

    for (NSDictionary* dict in userarr) {
        NSXMLElement* item = [NSXMLElement elementWithName:@"item"];

        [item addAttributeWithName:@"jid" stringValue:[dict objectForKey:@"jidstr"]];

        [query addChild:item];
    }

    [iq addChild:query];

    NSLog(@"checkUser:%@", iq);
    [xmppStream sendElement:iq];
}

- (void)addUserToRoom:(NSString*)roomjidstr userjidstr:(NSString*)jidstr roomname:(NSString*)inviteMessageStr
{
    // <message to='darkcave@chat.shakespeare.lit'>
    //   <x xmlns='http://jabber.org/protocol/muc#user'>
    //     <invite to='hecate@shakespeare.lit'>
    //       <reason>
    //         Hey Hecate, this is the place for all good witches!
    //       </reason>
    //     </invite>
    //   </x>
    // </message>
    XMPPJID* myJID = [XMPPJID jidWithString:jidstr];
    NSXMLElement* invite = [NSXMLElement elementWithName:@"invite"];
    [invite addAttributeWithName:@"to" stringValue:[myJID full]];

    if ([inviteMessageStr length] > 0) {
        [invite addChild:[NSXMLElement elementWithName:@"reason" stringValue:inviteMessageStr]];
    }

    NSXMLElement* x = [NSXMLElement elementWithName:@"x" xmlns:XMPPMUCUserNamespace];
    [x addChild:invite];

    XMPPMessage* message = [XMPPMessage message];
    //把邀请当做消息来做
    NSXMLElement* body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:@"i"];
    [message addChild:body];

    [message addAttributeWithName:@"to" stringValue:roomjidstr];
    [message addChild:x];

    [xmppStream sendElement:message];
}

- (void)sendChatMessage:(NSString*)fromjidstr type:(NSString*)type body:(NSString*)msg voicelenth:(NSString*)vl msgID:(NSString*)msgID
{
    NSLog(@"%@", vl);
    XMPPJID* tempjid = [XMPPJID jidWithString:fromjidstr];
    XMPPMessage* message = [XMPPMessage messageWithType:@"chat" to:tempjid];
    [message addAttributeWithName:@"id" stringValue:msgID];
    if ([type isEqualToString:@"voice"]) {
        [message addvoicelenth:vl];
    }
    [message addSubject:type];
    [message addBody:msg];
    [message addtime:[Tool Get1970time]];
    NSXMLElement* receipt = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
    [message addChild:receipt];
    NSLog(@"%@", message);
    [xmppStream sendElement:message];
}
- (void)sendChatRoomMessage:(NSString*)fromjidstr type:(NSString*)type body:(NSString*)msg voicelenth:(NSString*)vl msgID:(NSString*)msgID
{
    XMPPJID* tempjid = [XMPPJID jidWithString:fromjidstr];
    NSString* device = [DeviceHard deviceString];
    NSString* from = [NSString stringWithFormat:@"%@/%@", [[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID], device];
    XMPPMessage* message = [XMPPMessage messageWithType:@"groupchat" to:tempjid];
    [message addAttributeWithName:@"id" stringValue:msgID];
    NSString* voicetype = type;
    if ([type isEqualToString:@"voice"]) {
        // [message addvoicelenth:vl];
        voicetype = [NSString stringWithFormat:@"%@|%@", type, vl];
    }
    [message addAttributeWithName:@"from" stringValue:from];
    [message addSubject:voicetype];
    [message addBody:msg];
    //[message addtime:[Tool Get1970time]];
    NSLog(@"%@", message);
    [xmppStream sendElement:message];
}

- (void)photoChange
{
    XMPPPresence* presence = [XMPPPresence presence]; // type="available" is implicit
    NSXMLElement* x = [NSXMLElement elementWithName:@"x" xmlns:@"vcard-temp:x:update"];
    [presence addChild:x];
    NSLog(@"%@", presence);
    [xmppStream sendElement:presence];
}

- (void)getAllMyRoom
{

    XMPPIQ* iq = [XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"ALLROOMS"];
    NSXMLElement* query = [NSXMLElement elementWithName:@"query" xmlns:@"talkKing:iq:rooms"];
    [iq addChild:query];
    NSLog(@"%@", iq);
    [xmppStream sendElement:iq];
}

- (void)GetRoomInfo:(NSString*)roomjidstr
{
    //    <iq from='hag66@shakespeare.lit/pda'
    //    id='disco3'
    //    to='darkcave@macbeth.shakespeare.lit'
    //    type='get'>
    //    <query xmlns='http://jabber.org/protocol/disco#info'/>
    //    </iq>

    XMPPJID* myJID = self.xmppStream.myJID;
    XMPPIQ* iq = [XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"id" stringValue:@"ONEROOMINFO"];
    [iq addAttributeWithName:@"from" stringValue:myJID.full];
    [iq addAttributeWithName:@"to" stringValue:roomjidstr];

    NSXMLElement* query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"];
    [iq addChild:query];

    NSLog(@"%@", iq);
    [xmppStream sendElement:iq];
}

@end
