//
//  MainViewController.m
//  IMReasonable
//
//  Created by apple on 14/12/22.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "MainViewController.h"
#import "ChatListViewController.h"
#import "ContactsViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AppDelegate.h"
#import "AnimationHelper.h"
#import "ASIFormDataRequest.h"
#import "SetterViewController.h"
#import "FriendsCircleViewController.h"


@interface MainViewController ()
{
    NSMutableArray*  allLacalUser;
}
- (void)creatControls;
- (void)getlocaluser;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    if (![XMPPDao sharedXMPPManager].xmppStream.isConnected) {
        [[XMPPDao sharedXMPPManager] connect];
    }

    [XMPPDao sharedXMPPManager].authloginDelegate = self;
    [self creatControls];


    allLacalUser=[IMReasonableDao getAllLocalUser];//所有本地手机通讯录
    [self registerCallback];//修改通讯录后
    
    
    
    //预防在线升级 群数据无法获取的问题，每升级一次就触发一次拉取群的操作
    NSString * version=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    bool isFirstGetLocal=[defaults boolForKey:version];
    if (!isFirstGetLocal) {
        [[XMPPDao sharedXMPPManager] getAllMyRoom];
        [defaults setBool:true forKey:version];
        [defaults synchronize];
    }

  
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeItem)
                                                 name:@"CHANGEITEM"
                                               object:nil];
}




- (void)changeItem
{
    self.selectedIndex=0;
}
//注册通讯录变化
- (void)registerCallback {
    
    if (self.addressBook==nil) {
        
        if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
            self.addressBook=ABAddressBookCreateWithOptions(NULL, NULL);
            dispatch_semaphore_t sema=dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool greanted, CFErrorRef error){
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
        }
    };
    
    if (!_hasRegister) {
        ABAddressBookRegisterExternalChangeCallback(self.addressBook, addressCallback, (__bridge void *)(self));
        _hasRegister = YES ;

    }
}

- (void)unregisterCallback {
    if (_hasRegister) {
        ABAddressBookUnregisterExternalChangeCallback(_addressBook, addressCallback, (__bridge void *)(self));
        _hasRegister = NO;
    }
}

//收到通讯录变化
void addressCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
    if (addressBook==nil) {
        return ;
    };
    [(__bridge MainViewController*)context getlocaluser];
}



- (void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
   
}
- (void)getlocaluser
{

    
     dispatch_async(dispatch_get_global_queue(0, 0), ^{
         
         NSMutableDictionary * dict=[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1",@"action", nil];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"CONNECTSCHANGE"
                                                             object:self userInfo:dict];
         
         ABAddressBookRef tmpAddressBook = nil;
         //根据系统版本不同，调用不同方法获取通讯录
         if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
             tmpAddressBook=ABAddressBookCreateWithOptions(NULL, NULL);
             dispatch_semaphore_t sema=dispatch_semaphore_create(0);
             ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
                 dispatch_semaphore_signal(sema);
             });
             dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
             
         }
         if (tmpAddressBook==nil) {
             return ;
         };

         CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
         
       NSString* myphone= [[[[NSUserDefaults standardUserDefaults] objectForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
         
     //在这里边获取所有的联系人
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        //读取firstname
        NSString *firstname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
       //读取lastname
        NSString *lastname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        
         NSString * fullname;
        
        
         NSInteger personID = ABRecordGetRecordID(person);
        
            if ([Tool isHaveChinese:firstname]) {
                 fullname=[NSString stringWithFormat:@"%@%@",lastname?lastname:@"",firstname?firstname:@""];
            
            }else{
        fullname=[NSString stringWithFormat:@"%@ %@",firstname?firstname:@"",lastname?lastname:@""];
            }
        
        if ([fullname isEqualToString:@"深圳jelly"]) {
            NSLog(@"%@",fullname);
        }
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
          //  获取該Label下的电话值
            NSString * tmpPhoneIndex = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
        
                NSString * unknowphone=[tmpPhoneIndex substringWithRange:NSMakeRange(0,1)];
                tmpPhoneIndex=[Tool getPhoneNumber:tmpPhoneIndex];
                NSString * flag=@"0";
                 if (![tmpPhoneIndex isEqualToString:@""]) {
            
                         if (![unknowphone isEqualToString:@"+"]) {//需要当前用户的国家代码
                            NSString * countrycode=[[NSUserDefaults standardUserDefaults] objectForKey:XMPPUSERCOUNTRYCODE];
                            tmpPhoneIndex=[NSString stringWithFormat:@"%@%@",countrycode,tmpPhoneIndex];
                         }
            
                          if (![tmpPhoneIndex isEqualToString:myphone]) { //过滤掉自己的电话号码
                                 [[XMPPDao sharedXMPPManager] XMPPAddFriendSubscribe:tmpPhoneIndex]; //不管是不是openfire的用户得发送邀请
                                 [IMReasonableDao saveUserLocalNick:tmpPhoneIndex image:fullname addid:[NSString stringWithFormat:@"%ld",(long)personID]  isImrea:flag phonetitle:personPhoneLabel];// 保存到本地数据库
                          }
                     
                 }
          
        }
        
    }
         
         CFRelease(results);
         CFRelease(tmpAddressBook);
         
         [self GetAllRegUser];
         
     });
    
    
    
   
    
}


- (void)GetAllRegUser{
    
    NSMutableArray * alluser=[IMReasonableDao getAllUser];
    if (alluser.count>0) {
        [[XMPPDao sharedXMPPManager] checkUser:alluser];
    }else{
        NSMutableDictionary * dict=[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"2",@"action", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CONNECTSCHANGE"
                                                        object:self userInfo:dict];
    }
    
}

- (void) checkUserArrSuc:(ASIHTTPRequest *) req{
    
   

    //请求成功了，就需要邀请成为朋友，并标记本地数据库的值为激活用户
    NSData *responsedata=[req responseData];
    NSDictionary * data=[Tool jsontodate:responsedata];
    NSDictionary *code=[data objectForKey:@"CheckByArrResult"];
    NSString * state=[code objectForKey:@"state"];
    if ([state isEqualToString:@"1"]) {
        NSArray * user=[code objectForKey:@"userarr"];
        if ( ![user isKindOfClass:[NSNull class]]  && user != nil && user.count != 0) {//如果有用户是使用过的
            NSString * data=@"";
            for (int i=0; i<user.count; i++) {
                
                NSString * phone=[user objectAtIndex:i];
                if (phone && ![phone isEqualToString:@""]) {
                    data=[NSString stringWithFormat:@"%@,%@",phone,data];
                   
                    [[XMPPDao sharedXMPPManager] queryOneRoster:[NSString stringWithFormat:@"%@%@",phone,XMPPSERVER2]];//请求该联系人的信息
                }
                
            }
            
            if (data && data.length>2) {
                
                NSString *indata = [data substringToIndex:data.length - 1];
                [IMReasonableDao  updateUserIsLocal:indata];
                
            }
            
            
        }
        
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CONNECTSCHANGE"
                                                        object:self];
    
    
}
- (void) checkUserArrFaied:(ASIHTTPRequest *) req{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CONNECTSCHANGE"
                                                        object:self];
}



//是不是本地openfire用户
- (BOOL)isHave:(NSString *)phonenumber
{
    BOOL flag=false;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.jidstr == %@", phonenumber];
    NSArray *results = [allLacalUser filteredArrayUsingPredicate:predicate];
    
    if ([results count]>0) {//已经是本地openfire的用户咯
        flag=true;
    }
    return flag;
}


//将试图控制器添加到tabbar上面
- (void)creatControls
{
    //通讯录
    ContactsViewController * contactsViewController=[[ContactsViewController alloc] init];
    contactsViewController.tabBarItem.image=[UIImage imageNamed:@"tab_1"];
    contactsViewController.tabBarItem.title=NSLocalizedString(@"lbcontacts",nil);//个人收藏
    
    
    UINavigationController * nvifirst=[[UINavigationController alloc] init];
    [nvifirst addChildViewController:contactsViewController];
    
    //聊天列表
    ChatListViewController * chatListViewController=[[ChatListViewController alloc]init];
    chatListViewController.tabBarItem.image=[UIImage imageNamed:@"tab_0"];
    chatListViewController.tabBarItem.title=NSLocalizedString(@"lbchats",nil);//消息
    UINavigationController * nvisecond=[[UINavigationController alloc] init];
    [nvisecond addChildViewController:chatListViewController];
    
//    //朋友圈数据
//    FriendsCircleViewController * friendscircle=[[FriendsCircleViewController alloc] init];
//    friendscircle.tabBarItem.image=[UIImage imageNamed:@"tab_3.png"];
//    friendscircle.tabBarItem.title=NSLocalizedString(@"FOUND",nil);//朋友圈
//    UINavigationController * four=[[UINavigationController alloc] init];
//    [four addChildViewController:friendscircle];
    
    //我
    SetterViewController * chatroomlist=[[SetterViewController alloc] init];
    chatroomlist.tabBarItem.image=[UIImage imageNamed:@"tab_2"];
    chatroomlist.tabBarItem.title=NSLocalizedString(@"lbsetter",nil);  //通讯录
    UINavigationController * third=[[UINavigationController alloc] init];
    [third addChildViewController:chatroomlist];

    
    
    NSArray * controls=[NSArray arrayWithObjects:nvisecond,nvifirst, third,nil];
    self.viewControllers=controls;
    
   self.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-49);
    self.selectedIndex=0;
    
}

#pragma mark-AuthLoginDelegate
- (void) isSuccLogin:(BOOL)flag
{
    //[Tool alert:@"登陆成功"];
}

- (void) isSuccReg:(BOOL)flag
{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) viewDidAppear:(BOOL)animated
{
    [self.selectedViewController endAppearanceTransition];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.selectedViewController beginAppearanceTransition: NO animated: animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [self.selectedViewController endAppearanceTransition];
}

- (void)dealloc
{
    [self unregisterCallback];
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



@end
