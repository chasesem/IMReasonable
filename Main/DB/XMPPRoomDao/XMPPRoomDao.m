//
//  XMPPRoomDao.m
//  IMReasonable
//
//  Created by apple on 15/3/18.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "XMPPRoomDao.h"
#import "XMPPDao.h"

@implementation XMPPRoomDao
{
     XMPPRoom * xmppRoom;
    XMPPRoomCoreDataStorage*_storage ;
}
@synthesize xmppRoom;
+ (XMPPRoomDao*)sharedXMPPManager{
    static XMPPRoomDao *sharedXMPPManager=nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedXMPPManager=[[self alloc] init];
    });
    return sharedXMPPManager;
}
- (id)init
{
    self = [super init];
    if(self){
       _storage = [[XMPPRoomCoreDataStorage alloc] init];
        //[XMPPDao sharedXMPPManager].xmppStream.
        
    }
    return self;
}


- (void)createRoom:(NSString *)roomname {
    
    XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@muc.%@",roomname,XMPPSERVER]];
    xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_storage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:[XMPPDao sharedXMPPManager].xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
     NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
    [[myJID componentsSeparatedByString:@"@"] objectAtIndex:0];
    [xmppRoom joinRoomUsingNickname:myJID history:nil];
    
    
}

- (void)ChangeSubject:(NSString*)roomjidstr subject:(NSString *)subject
{

//    <message
//    from='wiccarocks@shakespeare.lit/laptop'
//    to='darkcave@chat.shakespeare.lit'
//    type='groupchat'>
//    <subject>Fire Burn and Cauldron Bubble!</subject>
//    </message>

}

////[_xmppRoom inviteUser:myxmppjid withMessage:@"TEST"];
- (void)InviteUser:(NSString *)jidstr subject:(NSString *)subject
{
     XMPPJID * myxmppjid= [XMPPJID jidWithString:jidstr];
    [xmppRoom inviteUser:myxmppjid withMessage:subject];
}

-(void)SetAdmin:(NSString *)formjidstr roomjidstr:(NSString *)roomjidstr user:(NSArray *)arr
{
//    <iq from='crone1@shakespeare.lit/desktop'
//    id='admin1'
//    to='darkcave@chat.shakespeare.lit'
//    type='set'>
//    <query xmlns='http://jabber.org/protocol/muc#admin'>
//    <item affiliation='admin'
//    jid='wiccarocks@shakespeare.lit'/>
//    </query>
//    </iq>
    
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"from" stringValue:formjidstr];
    [iq addAttributeWithName:@"to" stringValue:roomjidstr];
    NSXMLElement *vElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/muc#admin"];
    for (NSString *temp in arr) {
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
        [item addAttributeWithName:@"affiliation" stringValue:@"admin"];
        [item addAttributeWithName:@"jid" stringValue:temp];
        [vElement addChild:item];
    }
    [iq addChild:vElement];
    [[XMPPDao sharedXMPPManager].xmppStream sendElement:iq];

    
    
}

#pragma mark - xmpproom delegate
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    NSLog(@"%@",sender);
    
    
   // [self.roomHelerpDelegate creatRoomResult:2];//房间创建成功但是未配置
    [sender fetchConfigurationForm];
    
  
}
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    NSLog(@"%s",__func__);

    NSMutableDictionary * confdict=[self parserConfigElement:configForm];
    [self.roomHelerpDelegate GetRoomConfigForm:confdict];
}


-(NSMutableDictionary*)getRoomConfig:(NSMutableDictionary*)con user:(NSMutableArray *) arr subject:(NSString *)subject
{
    if([con count]){
        NSMutableArray * fields=[con objectForKey:@"fields"];
      //  NSString * subject=@"TRY";
        
        //深圳聊天室的名字
        NSDictionary * item0=[fields objectAtIndex:0];
        NSMutableArray * item0children=[item0 objectForKey:@"children"];
        NSDictionary * vaule0=[[NSDictionary alloc]initWithObjectsAndKeys:subject,@"text",subject,@"value", nil];
        [item0children replaceObjectAtIndex:0 withObject:vaule0];
        [item0 setValue:item0children forKey:@"children"];
        [fields replaceObjectAtIndex:0 withObject:item0];
        
        //设置聊天室的主题
        NSDictionary * item1=[fields objectAtIndex:1];
        NSMutableArray * item1children=[item1 objectForKey:@"children"];
        NSDictionary * vaule1=[[NSDictionary alloc]initWithObjectsAndKeys:subject,@"text",subject,@"value", nil];
        [item1children replaceObjectAtIndex:0 withObject:vaule1];
        [item1 setValue:item1children forKey:@"children"];
        [fields replaceObjectAtIndex:1 withObject:item1];
        
        //设置聊天室为永久的
        NSDictionary * item2=[fields objectAtIndex:2];
        NSMutableArray * item2children=[item2 objectForKey:@"children"];
        NSDictionary * vaule2=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"text",@"1",@"value", nil];
        [item2children replaceObjectAtIndex:0 withObject:vaule2];
        [item2 setValue:item2children forKey:@"children"];
        [fields replaceObjectAtIndex:2 withObject:item2];
        
        //设置房间是适度的
        NSDictionary * item4=[fields objectAtIndex:4];
        NSMutableArray * item4children=[item4 objectForKey:@"children"];
        NSDictionary * vaule4=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"text",@"0",@"value", nil];
        [item4children replaceObjectAtIndex:0 withObject:vaule4];
        [item4 setValue:item4children forKey:@"children"];
        [fields replaceObjectAtIndex:4 withObject:item4];
        
        //设置房间只对成员开发
        NSDictionary * item5=[fields objectAtIndex:5];
        NSMutableArray * item5children=[item5 objectForKey:@"children"];
        NSDictionary * vaule5=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"text",@"1",@"value", nil];
        [item5children replaceObjectAtIndex:0 withObject:vaule5];
        [item5 setValue:item5children forKey:@"children"];
        [fields replaceObjectAtIndex:5 withObject:item5];
        
        
        //不需要密码
        NSDictionary * item6=[fields objectAtIndex:6];
        NSMutableArray * item6children=[item6 objectForKey:@"children"];
        NSDictionary * vaule6=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"text",@"0",@"value", nil];
        [item6children replaceObjectAtIndex:0 withObject:vaule6];
        [item6 setValue:item6children forKey:@"children"];
        [fields replaceObjectAtIndex:6 withObject:item6];
        
        
        NSDictionary * item8=[fields objectAtIndex:8];
        NSMutableArray * item8children=[[NSMutableArray alloc] init];  //[item8 objectForKey:@"children"];
        NSDictionary * vaule8=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"text",@"nonanonymous",@"value", nil];
        [item8children addObject:vaule8];
        // [item8children replaceObjectAtIndex:0 withObject:vaule8];
        [item8 setValue:item8children forKey:@"children"];
        [fields replaceObjectAtIndex:8 withObject:item8];
        
        
        
        
        //设置房间
        NSDictionary * item9=[fields objectAtIndex:9];
        NSMutableArray * item9children=[item9 objectForKey:@"children"];
        NSDictionary * vaule9=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"text",@"1",@"value", nil];
        [item9children replaceObjectAtIndex:0 withObject:vaule9];
        [item9 setValue:item9children forKey:@"children"];
        [fields replaceObjectAtIndex:9 withObject:item9];
        
        //设置房间只对成员开放
        NSDictionary * item10=[fields objectAtIndex:10];
        NSMutableArray * item10children=[item10 objectForKey:@"children"];
        NSDictionary * vaule10=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"text",@"1",@"value", nil];
        [item10children replaceObjectAtIndex:0 withObject:vaule10];
        [item10 setValue:item10children forKey:@"children"];
        [fields replaceObjectAtIndex:10 withObject:item10];

        
        //设置房间允许占有者邀请好友
//        NSDictionary * item11=[fields objectAtIndex:11];
//        NSMutableArray * item11children=[item11 objectForKey:@"children"];
//        NSDictionary * vaule11=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"text",@"1",@"value", nil];
//        [item11children replaceObjectAtIndex:0 withObject:vaule11];
//        [item11 setValue:item11children forKey:@"children"];
//        [fields replaceObjectAtIndex:11 withObject:item11];
        
        
        NSDictionary * item15=[fields objectAtIndex:15];
        NSMutableArray * item15children=[[NSMutableArray alloc] init];  //[item14 objectForKey:@"children"];
        NSDictionary * vaule15_1=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"text",@"admin",@"value", nil];
        NSDictionary * vaule15_2=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"text",@"member",@"value", nil];
        NSDictionary * vaule15_3=[[NSDictionary alloc]initWithObjectsAndKeys:@"1",@"text",@"owner",@"value", nil];
        [item15children addObject:vaule15_1];
        [item15children addObject:vaule15_2];
        [item15children addObject:vaule15_3];
        [item15 setValue:item15children forKey:@"children"];
        [fields replaceObjectAtIndex:15 withObject:item15];

        
     
        
        
        [con setObject:fields forKey:@"fields"];

    }
    
    return con;
    
}

- (NSXMLElement*)DictToBSXMLElement:(NSMutableDictionary*)dict
{
    
    NSXMLElement *xElement = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * fullPathToFile= [documentsDirectory stringByAppendingPathComponent:@"a.plist"];
    [dict writeToFile:fullPathToFile atomically:YES];
    
    
    
    
    
    NSArray *fields = [dict objectForKey:@"fields"];
    for (NSDictionary *dic in fields) {
        NSDictionary *attribute = [dic objectForKey:@"attributes"];
        NSArray *children = [dic objectForKey:@"children"];
        NSXMLElement *fieldElement = [NSXMLElement elementWithName:@"field"];
        for (NSString *key in attribute.allKeys) {
            [fieldElement addAttributeWithName:key stringValue:[attribute objectForKey:key]];
        }
        
        for (NSDictionary *dic in children) {
            if ([dic objectForKey:@"option"]) {
                NSXMLElement *optionElement = [NSXMLElement elementWithName:@"option"];
                if ([dic objectForKey:@"label"]) {
                    [optionElement addAttributeWithName:@"label" stringValue:[dic objectForKey:@"label"]];
                }
                if ([dic objectForKey:@"value"]) {
                    [optionElement addChild:[NSXMLElement elementWithName:@"value" stringValue:[dic objectForKey:@"value"]]];
                }
                [fieldElement addChild:optionElement];
            }else if([dic objectForKey:@"value"]){
                [fieldElement addChild:[NSXMLElement elementWithName:@"value" stringValue:[dic objectForKey:@"value"]]];
            }
        }
        [xElement addChild:fieldElement];
    }
    
    return xElement;


}

- (NSMutableDictionary*)parserConfigElement:(NSXMLElement *)configForm
{
   // _postElement = configForm;
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    NSMutableArray *fields = [NSMutableArray array];
    for (DDXMLElement *element in [configForm children] ) {
        if ([element.name isEqualToString:@"field"]) {
            NSMutableDictionary *eleDic = [NSMutableDictionary dictionary];
            NSMutableDictionary *attributesDic = [NSMutableDictionary dictionary];
            NSMutableArray *childrenArray = [NSMutableArray array];
            for (DDXMLElement *attri in element.attributes) {
                //                [attributesArray addObject:@{attri.name: attri.stringValue}];
                [attributesDic setObject:attri.stringValue forKey:attri.name];
            }
            
            for (DDXMLElement *childrenEle in element.children) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                
                if (childrenEle.attributes.count > 0 ) {
                    for (DDXMLElement *ele in childrenEle.attributes) {
                        [dic setObject:ele.stringValue forKey:ele.name];
                    }
                }
                
                if (childrenEle.name.length > 0 ) {
                    [dic setObject:childrenEle.stringValue forKey:childrenEle.name];
                    
                    if (childrenEle.childCount > 0) {
                        for (DDXMLElement *ele in childrenEle.children) {
                            [dic setObject:ele.stringValue forKey:ele.name];
                        }
                    }
                }
                [childrenArray addObject:dic];
            }
            [eleDic setObject:attributesDic forKey:@"attributes"];
            [eleDic setObject:childrenArray forKey:@"children"];
            [fields addObject:eleDic];
        }else{
            [resultDic setObject:element.stringValue forKey:element.name];
        }
    }
    [resultDic setObject:fields forKey:@"fields"];
    //_postDic = resultDic;
    return resultDic;
   
}


- (void)xmppRoom:(XMPPRoom *)sender willSendConfiguration:(XMPPIQ *)roomConfigForm
{
    NSLog(@"%@",roomConfigForm);
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    //配置房间成功，可以邀请人进入房间聊天了
    
     //  XMPPJID * myxmppjid= [XMPPJID jidWithString:@"admin@talk-king.net"];
   // [_xmppRoom inviteUser:myxmppjid withMessage:@"TEST"];
    
    [self.roomHelerpDelegate creatRoomResult:3];

}
- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult
{
    
    [self.roomHelerpDelegate creatRoomResult:1];
    NSLog(@"%@",iqResult);
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"failed" message:iqResult.description delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//    [alert show];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    NSLog(@"%@",sender.description);
    
   // _roomVC.roomName = sender.roomJID.user;
  //  _roomVC.xmppRoom = _xmppRoom;
   // [self.navigationController pushViewController:_roomVC animated:YES];
}
- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    NSLog(@"%@",sender.description);
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender
{
    NSLog(@"%@",sender.description);
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"jid:%@  presence ; %@",occupantJID,presence);
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"jid:%@  presence ; %@",occupantJID,presence);
    
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"jid:%@  presence ; %@",occupantJID,presence);
    
}

/**
 * Invoked when a message is received.
 * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
 **/
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items
{
    NSLog(@"%@",items);
  //  [_roomVC  listMemberWithData:items type:memberType_ban];
}
//黑名单列表
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    NSLog(@"%@",items);
   //  NSString* roomjidstr=sender.roomJID.bare;
  //   NSString*subject=[sender roomSubject];
    
   // [_roomVC listMemberWithData:items type:memberType_members];

 //再次获取成员列表
    
    
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
    
}
//管理员名单
- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    NSLog(@"%@",items);
  //  [_roomVC listMemberWithData:items type:memberType_moderators];
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
    
}

- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult
{
    NSLog(@"%@",iqResult);
}
- (void)xmppRoom:(XMPPRoom *)sender didNotEditPrivileges:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
}



@end
