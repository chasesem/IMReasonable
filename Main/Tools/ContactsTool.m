//
//  ContactsTool.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/13.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "Person.h"
#import "SendEmailInvitationEntity.h"
#import "PJSendInviteHttpTool.h"
#import "ContactsTool.h"
#import <AddressBook/AddressBook.h>
#import "AnimationHelper.h"
#import "XMPPDao.h"
#import "IMReasonableDao.h"

#define CH @"86"
#define HK @"852"
#define USETALKING @"Use Talkking"
#define GETALLPHONE 0 //获取所有的手机号码
#define GETALLEMAIL 1 //获取所有的邮箱
#define STARTWITHONE @"1"
#define LENGTH11 11
#define LENGTH8 8
#define INVITE_ALL_FRIENDS_COMPLETE @"INVITE_ALL_FRIENDS_COMPLETE"
#define INVITEBODY @"InvitationBody"
#define BODY @"<!DOCTYPE HTML PUBLIC \'-//W3C//DTD HTML 4.01 Transitional//EN\'><html><body><div align=\'center\'><a href=\'https://app.rspread.com/\' target=\'_blank\' title=\'Spread\' style=\'text-decoration: none;\'><img src=\'http://app.rspread.com/images/spreadlogocn.jpg\' height=\'87\' width=\'105\' style=\'border: 0 none;color: #6dc6dd !important;font-family: Helvetica,Arial,sans-serif;font-size: 60px;font-weight: bold;height: auto !important;letter-spacing: -4px;line-height: 100%;outline: medium none;text-align: center;text-decoration: none;\'></a></div><div align=\'center\'><h1 style=\'color: #606060 !important; font-family: Helvetica, Arial,    sans-serif; font-size: 32px; font-weight: bold; letter-spacing: -1px; line-height: 115%; margin: 0; padding: 0; text-align: center;\'>%@</h1><br><font style=\'color: #606060;font-family: Helvetica, Arial, sans-serif; font-size: 15px;text-align: center;\'>Click and DownLoad Talkking.</font></div><br><div align=\'center\'><div align=\'center\'  style=\'background-color: #6DC6DD;width:100px;height:60px;line-height:60px;\'><a href=\'http://talk-king.net/d\' target=\'_blank\' style=\'color: #FFFFFF; text-decoration: none;\'>DownLoad Talkking</a></div></div><br><div align=\'center\'><font align=\'center\'  class=\'footerContent\' style=\'color: #606060; font-family: Helvetica, Arial, sans-serif; font-size: 13px; line-height: 125%;\'>Copyright<span style=\'border-bottom:1px dashed #ccc;z-index:1\' onclick=\'return false;\' data=\'2006-2015\'>2006-2015</span><br>Reasonable Software House Limited. All Rights Reserved.</font></div></body></html>"

@interface ContactsTool ()
/**
 *  群邀用到的变量
 */
//所有的talkking用户
@property (nonatomic, copy) NSArray* talkkingUserArray;
//所有的talkking用户字典
@property (nonatomic, copy) NSMutableDictionary* talkkingUserDic;
@end

@implementation ContactsTool

- (NSArray*)talkkingUserArray
{
    if (!_talkkingUserArray) {

        _talkkingUserArray = [IMReasonableDao getAllactiveUser];
    }
    return _talkkingUserArray;
}

- (NSDictionary*)talkkingUserDic
{
    if (!_talkkingUserDic) {

        _talkkingUserDic = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < self.talkkingUserArray.count; i++) {
            /**
             *  key=phone;value=phone
             *
             *  @param model.phonenumber <#model.phonenumber description#>
             *
             *  @return <#return value description#>
             */
            IMChatListModle* model = _talkkingUserArray[i];
            if (model.phonenumber) {

                [_talkkingUserDic setObject:model.phonenumber forKey:model.phonenumber];
            }
        }
    }
    return _talkkingUserDic;
}

//去除国家代码前缀(目前只去除香港和大陆的)
-(NSString *)CutPhoneArea:(NSString *)phone{
    NSRange range = [phone rangeOfString:CH];
    //去除本机号码的国家代码前缀(86,852)
    if (range.length > 0 && range.location == 0) {
        
        phone = [phone substringFromIndex:range.length];
    }
    else {
        
        range = [phone rangeOfString:HK];
        if (range.length > 0 && range.location == 0) {
            
            phone = [phone substringFromIndex:range.length];
        }
    }
    return phone;
}

+(NSString *)DidCutPhoneArea:(NSString *)phone{
    return [[[self alloc] init] CutPhoneArea:phone];
}

+ (NSArray*)AllPerson
{
    return [[[self alloc] init] GetAllPerson];
}

+ (NSArray*)AllPhoneAndEmail
{
    return [[[self alloc] init] GetAllPhoneAndAllEmail];
}

//获取所有的手机号码和邮箱地址
- (NSArray*)GetAllPerson
{
    __block NSMutableArray* array = [NSMutableArray array];
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
        array = GetAllPerson_Block(results);
        CFRelease(results);
        CFRelease(addressBook);
    });
    return array;
}

//获取所有的手机号码和邮箱地址
- (NSArray*)GetAllPhoneAndAllEmail
{
    __block NSMutableArray* array = [NSMutableArray array];
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
        array = GetPhoneAndEmail_Block(results);
        CFRelease(results);
        CFRelease(addressBook);
    });
    return array;
}

//判断并修改手机号码
NSString* (^ForMatPhone_Block)(NSString*) = ^(NSString* personPhone) {
    NSString* phone;
    personPhone=[personPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (personPhone != nil && ![personPhone isEqualToString:@""]) {

        personPhone = [personPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
        personPhone = [personPhone stringByReplacingOccurrencesOfString:@"+" withString:@""];
        personPhone = [personPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
        //手机号码位数判断(香港的手机号码位数比大陆的少)
        if (personPhone.length >= 8) {

            //这边只判断大陆手机号码与香港手机号码
            if ([personPhone hasPrefix:STARTWITHONE]) { //以1开头的手机号码

                if (personPhone.length == LENGTH11) { //大陆未加86的手机号码

                    personPhone = [@"" stringByAppendingFormat:@"%@%@", CH, personPhone];
                }
            }
            else {

                if (personPhone.length == LENGTH8) { //香港未加前缀的手机号码

                    personPhone = [@"" stringByAppendingFormat:@"%@%@", HK, personPhone];
                }
            }
            phone = personPhone;
        }
    }
    return phone;
};

NSMutableArray* (^GetAllPerson_Block)(CFArrayRef) = ^(CFArrayRef results) {
    //存放所有的Person
    NSMutableArray* array = [NSMutableArray array];
    for (int i = 0; i < CFArrayGetCount(results); i++) {
        Person* per = [[Person alloc] init];
        NSMutableArray* phonearray = [NSMutableArray array];
        NSMutableArray* emailarray = [NSMutableArray array];
        //存放用户的名字或姓
        NSString* name;
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        //用户的姓
        NSString* personName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        //用户的名字
        NSString* lastName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        if ([Tool isBlankString:lastName]) {

            if ([Tool isBlankString:personName]) {

                name = NSLocalizedString(@"UNKNOW", nil);
            }
            else {

                name = personName;
            }
        }
        else {

            name = lastName;
        }
        per.name = name;
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        int phonecount = (int)ABMultiValueGetCount(phone);
        //标志是否是talkking用户
        BOOL isTalkkingUser = false;
        //当只有一个手机号码的情况
        if (phonecount == 1) {

            //获取該Label下的电话值
            NSString* personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
            NSString* phonestring = ForMatPhone_Block(personPhone);
            if (phonestring) {

                if (![[[ContactsTool alloc] init].talkkingUserDic objectForKey:phonestring]) {

                    [phonearray addObject:phonestring];
                }
                else {

                    isTalkkingUser = true;
                }
            }
        }
        else {

            for (int k = 0; k < phonecount; k++) {
                //获取該Label下的电话值
                NSString* personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
                NSString* phonestring = ForMatPhone_Block(personPhone);
                if (phonestring) {

                    if (![[[ContactsTool alloc] init].talkkingUserDic objectForKey:phonestring]) {

                        [phonearray addObject:phonestring];
                    }
                }
            }
        }
        per.phoneArray = phonearray;
        if (!isTalkkingUser) {

            //获取email多值
            ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
            int emailcount = (int)ABMultiValueGetCount(email);
            //获取邮件
            for (int x = 0; x < emailcount; x++) {
                //获取email值
                NSString* emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, x);
                //邮箱格式验证
                if ([Tool isValidateEmail:emailContent]) {

                    [emailarray addObject:emailContent];
                }
            }
            per.emailArray = emailarray;
        }
        else {

            isTalkkingUser = false;
        }
        if (per.phoneArray.count>0 || per.emailArray.count > 0) {

            [array addObject:per];
        }
    }
    return array;
};

/**
 *  群邀说明:一个用户可能含有多个手机号码和多个邮箱，邀请时如果该用户只有一个手机号码则如果该用户已经是talkking用户则不发邮箱邀请，如果该用户含有多个手机号码并且其中有一个手机号码是talkking则发邀请到该用户的邮箱，不管其邮箱有多少个
 *
 *  @param CFArrayRef <#CFArrayRef description#>
 *
 *  @return {{存放手机号码的集合}，{存放邮箱的集合}}存放的是非talkking用户
 */
NSMutableArray* (^GetPhoneAndEmail_Block)(CFArrayRef) = ^(CFArrayRef results) {
    NSMutableArray* array = [NSMutableArray array];
    NSMutableArray* phonearray = [NSMutableArray array];
    NSMutableArray* emailarray = [NSMutableArray array];
    for (int i = 0; i < CFArrayGetCount(results); i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        int phonecount = (int)ABMultiValueGetCount(phone);
        //标志是否是talkking用户
        BOOL isTalkkingUser = false;
        //当只有一个手机号码的情况
        if (phonecount == 1) {

            //获取該Label下的电话值
            NSString* personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
            NSString* phonestring = ForMatPhone_Block(personPhone);
            if (phonestring) {

                if (![[[ContactsTool alloc] init].talkkingUserDic objectForKey:phonestring]) {

                    [phonearray addObject:phonestring];
                }
                else {

                    isTalkkingUser = true;
                }
            }
        }
        else {

            for (int k = 0; k < phonecount; k++) {
                //获取該Label下的电话值
                NSString* personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
                NSString* phonestring = ForMatPhone_Block(personPhone);
                if (phonestring) {

                    if (![[[ContactsTool alloc] init].talkkingUserDic objectForKey:phonestring]) {

                        [phonearray addObject:phonestring];
                    }
                }
            }
        }

        if (!isTalkkingUser) {

            //获取email多值
            ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
            int emailcount = (int)ABMultiValueGetCount(email);
            //获取邮件
            for (int x = 0; x < emailcount; x++) {
                //获取email值
                NSString* emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, x);
                //邮箱格式验证
                if ([Tool isValidateEmail:emailContent]) {

                    [emailarray addObject:emailContent];
                }
            }
        }
        else {

            isTalkkingUser = false;
        }
    }
    [array addObject:phonearray];
    [array addObject:emailarray];
    return array;
};

//发送邀请短信，如果是talking用户则发送好友邀请
- (void)sendTalkingInvite:(id)requestObject
{

    NSDictionary* data = requestObject;
    NSDictionary* code = [data objectForKey:@"SendInvitationResult"];
    NSInteger state = (NSInteger)[code valueForKey:@"count"];
    if (state > 0) {
        NSArray* user = [code objectForKey:@"userarr"];
        if (![user isKindOfClass:[NSNull class]] && user != nil && user.count != 0) { //如果有用户是使用过的
            NSString* data = @"";
            for (int i = 0; i < user.count; i++) {

                NSString* phone = [user objectAtIndex:i];
                if (phone && ![phone isEqualToString:@""]) {
                    data = [NSString stringWithFormat:@"%@,%@", phone, data];
                    [[XMPPDao sharedXMPPManager] XMPPAddFriendSubscribe:phone]; //是openfire的用户就发送好友邀请
                    [[XMPPDao sharedXMPPManager] queryOneRoster:[NSString stringWithFormat:@"%@%@", phone, XMPPSERVER2]]; //请求该联系人的信息
                }
            }
            if (data && data.length > 2) {

                NSString* indata = [data substringToIndex:data.length - 1];
                [IMReasonableDao updateUserIsLocal:indata];
            }
        }
    }
}

//群邀手机号码(phoneAndemailArray所有手机号码和邮箱和用户对于的名字)
- (void)InvitePhone:(NSArray*)phoneAndemailArray WithIndex:(int)index
{

    if (phoneAndemailArray != nil) {

        NSArray* phoneArray = phoneAndemailArray[GETALLPHONE];
        if (phoneArray != nil) {

            __block int inviteindex = index;
            if (phoneArray.count > 0 && inviteindex <= phoneArray.count - 1) {

                NSDictionary* param = [NSDictionary dictionaryWithObject:phoneArray[inviteindex] forKey:@"phone"];
                [PJSendInviteHttpTool SendInviteByPostWithParam:param
                    success:^(id success) {
                        NSLog(@"success");
                        inviteindex++;
                        [self sendTalkingInvite:success];
                        [self InvitePhone:phoneAndemailArray WithIndex:inviteindex];
                    }
                    failure:^(NSError* error) {
                        NSLog(@"error");
                        inviteindex++;
                        [self InvitePhone:phoneAndemailArray WithIndex:index];
                    }];
            }
            else {

                if (inviteindex > 0) {

                    //群邀手机号码完成，开始群邀邮箱
                    [self InviteEmail:phoneAndemailArray[GETALLEMAIL] WithIndex:0];
                }
                inviteindex = 0;
            }
        }
    }
}

//群邀邮箱
- (void)InviteEmail:(NSArray*)emailArray WithIndex:(int)index
{
    if (emailArray != nil) {

        __block int inviteindex = index;
        if (emailArray.count > 0 && inviteindex <= emailArray.count - 1) {

            NSString* phone = [[[[NSUserDefaults standardUserDefaults] objectForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
            SendEmailInvitationEntity* entity = [[SendEmailInvitationEntity alloc] init];
            entity.LoginEmail = LOGINEMAIL;
            entity.Password = PASSWORD;
            entity.From = FROM;
            entity.FromName = FROMNAME;
            entity.To = emailArray[inviteindex];
            entity.Subject = USETALKING;
            NSString* body = [NSString stringWithFormat:NSLocalizedString(INVITEBODY, nil), [self CutPhoneArea:phone]];
            //带样式的邮件邀请
            /*NSString *body=[NSString stringWithFormat:BODY,[NSString stringWithFormat:NSLocalizedString(INVITEBODY, nil),phone]];*/
            entity.Body = body;
            [PJSendInviteHttpTool SendEmailInviteByPostWithParam:entity
                success:^(id requestObject) {
                    inviteindex++;
                    [self InviteEmail:emailArray WithIndex:inviteindex];
                }
                failure:^(NSError* error) {
                    inviteindex++;
                    [self InviteEmail:emailArray WithIndex:inviteindex];
                }];
        }
        else {

            if (inviteindex > 0) {

                //群邀完成
                [Tool alert:NSLocalizedString(INVITE_ALL_FRIENDS_COMPLETE, nil)];
            }
            inviteindex = 0;
        }
    }
}

+ (void)DidInviteAllFriends:(NSArray*)phoneAndemailArray
{
    [[[self alloc] init] InvitePhone:phoneAndemailArray WithIndex:0];
}
@end
