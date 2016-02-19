//
//  SendViewController.m
//  IMReasonable
//
//  Created by apple on 15/1/9.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "SendViewController.h"
#import "ThirdViewController.h"
#import "AnimationHelper.h"
#import "ASIFormDataRequest.h"
#import "loginUserData.h"
#import "AppDelegate.h"
#import "DesHelper.h"
#import "MBProgressHUD.h"

@interface SendViewController () {
    NSInteger index;
    loginUserData* userdata;
    MBProgressHUD* HUD;
    int counttime;
    int smscount;
}

@end

@implementation SendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    
    [XMPPDao sharedXMPPManager].authloginDelegate = self;
    smscount = 0;
    index = 0;
    [self.txt becomeFirstResponder];
    self.txt.delegate = self;
    userdata = [self appDelegate].userdata;
    self.nav.title = [NSString stringWithFormat:@"+%@  %@", userdata.countrycode, userdata.phonenumber];

    self.progress.hidden = YES;

    self.Title1.text = NSLocalizedString(@"lbSTitle1", nil);
    self.Title2.text = NSLocalizedString(@"lbSTitle2", nil);
    [self.resect setTitle:NSLocalizedString(@"lbRectsms", nil) forState:UIControlStateNormal];
    [self.callme setTitle:NSLocalizedString(@"lbCallme", nil) forState:UIControlStateNormal];
    [self.resect setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self setNSTime];

    // Do any additional setup after loading the view from its nib.
}

- (AppDelegate*)appDelegate
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return delegate;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)setNSTime
{
    [self appDelegate].time = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changetime:) userInfo:nil repeats:YES];
    [[self appDelegate].time setFireDate:[NSDate distantFuture]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)validateNumber:(NSString*)number
{
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString* string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}
- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{

    BOOL flag = [self validateNumber:string];

    if (flag) {

        if ([string isEqualToString:@""]) {

            [self SetCode:@"_" isneedgo:NO];
            index -= 1;
        }
        else {
            index += 1;
            [self SetCode:string isneedgo:YES];
        }

        if (index > 6) {
            index = 6;
        }
    }

    return true;
}

- (void)SetCode:(NSString*)code isneedgo:(BOOL)flag
{

    switch (index) {
    case 0: {
        self.txtNum1.text = @"_";
        self.txtNum2.text = @"_";
        self.txtNum3.text = @"_";
        self.txtNum4.text = @"_";
        self.txtNum5.text = @"_";
        self.txtNum6.text = @"_";

    } break;
    case 1: {
        self.txtNum1.text = code;
        self.txtNum2.text = @"_";
        self.txtNum3.text = @"_";
        self.txtNum4.text = @"_";
        self.txtNum5.text = @"_";
        self.txtNum6.text = @"_";

    } break;
    case 2: {

        self.txtNum2.text = code;
        self.txtNum3.text = @"_";
        self.txtNum4.text = @"_";
        self.txtNum5.text = @"_";
        self.txtNum6.text = @"_";

    } break;
    case 3: {
        self.txtNum3.text = code;
        self.txtNum4.text = @"_";
        self.txtNum5.text = @"_";
        self.txtNum6.text = @"_";
    } break;
    case 4: {
        self.txtNum4.text = code;
        self.txtNum5.text = @"_";
        self.txtNum6.text = @"_";

    } break;
    case 5: {
         self.txtNum5.text = code;
        self.txtNum6.text = @"_";

    } break;
    case 6: {
        self.txtNum6.text = code;

    } break;

    default:
        break;
    }

    if (index == 6 && flag) {

        self.txt.text = [NSString stringWithFormat:@"%@A", self.txt.text];
        [self.txt resignFirstResponder];
        [self checksmscode];
    }
}

- (void)isneedgonext
{
    ThirdViewController* firstview = [[ThirdViewController alloc] initWithNibName:@"ThirdViewController" bundle:nil];
    [self presentViewController:firstview animated:YES completion:nil];
}

// 发起验证码验证的网络请求
- (void)checksmscode
{
    [AnimationHelper showHUD:NSLocalizedString(@"lbSchecksms", nil)];
    NSURL* url = [NSURL URLWithString:[Tool Append:IMReasonableAPP witnstring:@"CheckCode"]];
    NSString* Apikey = IMReasonableAPPKey;
    NSString* phone = [NSString stringWithFormat:@"%@%@", userdata.countrycode, userdata.phonenumber];
    NSString* smscode = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                                  self.txtNum1.text, self.txtNum2.text, self.txtNum3.text,
                                  self.txtNum4.text, self.txtNum5.text, self.txtNum6.text];
    NSDictionary* sendsms = [[NSDictionary alloc] initWithObjectsAndKeys:Apikey, @"apikey", phone, @"phone", smscode, @"smscode", nil];
    NSDictionary* sendsmsD = [[NSDictionary alloc] initWithObjectsAndKeys:sendsms, @"smscode", nil];
    if ([NSJSONSerialization isValidJSONObject:sendsmsD]) {
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:sendsmsD options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableData* tempJsonData = [NSMutableData dataWithData:jsonData];
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
        [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:tempJsonData];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(checkSmsSuc:)];
        [request setDidFailSelector:@selector(checkSmsFaied:)];
        [request startAsynchronous];
    }
}
//请求结果
- (void)checkSmsSuc:(ASIHTTPRequest*)req
{
    [AnimationHelper removeHUD];
    NSData* responsedata = [req responseData];
    NSDictionary* data = [Tool jsontodate:responsedata];
    NSDictionary* code = [data objectForKey:@"CheckCodeResult"];
    [self HaoDo:code];
}
- (void)checkSmsFaied:(ASIHTTPRequest*)req
{
    [self.txt becomeFirstResponder];
    [AnimationHelper removeHUD];
    PJLog(@"%@", [req error]);
    if ([XMPPDao sharedXMPPManager].isConnectInternet) {
        [self AlertMsg:NSLocalizedString(@"lbsmserr", nil)];
    }
    else {

        [self AlertMsg:NSLocalizedString(@"msgInternet", nil)];
    }
}

- (void)HaoDo:(NSDictionary*)dict
{
    NSString* errcode = [dict objectForKey:@"errcode"];
    NSString* phone = [dict objectForKey:@"phone"];
    NSString* password;
    @try {
        password=[dict objectForKey:@"password"];
        if(password!=nil&&![password isEqual:[NSNull null]]&&![password isEqualToString:@""]){
            
            password = [DesHelper textFromBase64String:password withKey:IMReasonableDESKey];
        }
    }
    @catch (NSException* exception) {
        errcode = @"-2";
    }

    NSInteger temp = -5;
    if (errcode.length > 0) {
        temp = [errcode integerValue];
    }
    //大于-1说明用户再中间服务器添加成功
    if (temp == 1) {

        [XMPPDao sharedXMPPManager].isReg = ![self isRegToOpenfire:phone];
        [self loginorReg:phone password:password];
    }
    else {

        [self.txt becomeFirstResponder];

        if ([errcode isEqualToString:@"-2"]) {
            [self AlertMsg:NSLocalizedString(@"lbsmserr", nil)];
        }

        if ([errcode isEqualToString:@"-1"]) {
            [self AlertMsg:NSLocalizedString(@"lbsmstimelong", nil)];
        }
    }
}

- (BOOL)isRegToOpenfire:(NSString*)phone
{
    NSURL* url = [NSURL URLWithString:[Tool Append:IMReasonableAPP witnstring:@"UserIsReg"]];
    NSString* Apikey = IMReasonableAPPKey;
    NSString* tempphone = phone;
    NSDictionary* data = [[NSDictionary alloc] initWithObjectsAndKeys:Apikey, @"apikey", tempphone, @"phone", nil];
    NSDictionary* sendsmsD = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"isreg", nil];
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
            NSString* code = [dict objectForKey:@"UserIsRegResult"];
            BOOL flag = false;
            [code isEqualToString:@"1"] ? (flag = true) : (flag = false);
            return flag;
        }
        else {

            return false;
        }
    }
    else {

        return false;
    }
}

- (void)loginorReg:(NSString*)jidstr password:(NSString*)pwd
{

    NSString* tempjidstr = [jidstr stringByAppendingString:XMPPSERVER2];
    [[NSUserDefaults standardUserDefaults] setObject:tempjidstr forKey:XMPPREASONABLEJID];
    [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:XMPPREASONABLEPWD];
    [[NSUserDefaults standardUserDefaults] setObject:userdata.countrycode forKey:XMPPUSERCOUNTRYCODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [AnimationHelper showHUD:@""];
    BOOL result=[[XMPPDao sharedXMPPManager] connect]; //登陆或者注册到服务器
    //如果是退出登录，则下次登录成功时无需再次创建数据库，表(即无需调用isSuccLogin方法)
    if(result&&[[NSUserDefaults standardUserDefaults] boolForKey:ISSIGN_OUT]){
        
        [AnimationHelper removeHUD];
        [self isneedgonext];
    }
}

- (void)isSuccLogin:(BOOL)flag
{
    [AnimationHelper removeHUD];

    if (flag) { //登陆成功立即创建自己的数据库
        [IMReasonableDao initIMReasonableTable];
        NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:true forKey:version];
        [defaults setBool:false forKey:USERELISTNEED];
        [defaults synchronize];

        [self isneedgonext];
    }
    else { //登陆失败
        [[XMPPDao sharedXMPPManager] disconnect];
        [self AlertMsg:NSLocalizedString(@"lbLoginFaied", nil)];

        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:XMPPREASONABLEJID];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:XMPPREASONABLEPWD];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:XMPPUSERCOUNTRYCODE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//当flag==true的时候表明注册成功，否则注册失败
- (void)isSuccReg:(BOOL)flag
{
    if (flag) {
        [AnimationHelper removeHUD];
        [AnimationHelper showHUD:@""];
        [XMPPDao sharedXMPPManager].isReg = false;
        [[XMPPDao sharedXMPPManager] disconnect];
        [[XMPPDao sharedXMPPManager] connect];
    }
    else {

        [self AlertMsg:@"注册失败请重试"];

        [[XMPPDao sharedXMPPManager] disconnect];
        [AnimationHelper removeHUD];
    }
}

- (void)ActiovUser
{
    NSURL* url = [NSURL URLWithString:[Tool Append:IMReasonableAPP witnstring:@"ActiveUser"]];
    NSString* Apikey = IMReasonableAPPKey;
    NSString* phone = [NSString stringWithFormat:@"%@%@", userdata.countrycode, userdata.phonenumber];
    NSString* smscode = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                                  self.txtNum1.text, self.txtNum2.text, self.txtNum3.text,
                                  self.txtNum4.text, self.txtNum5.text, self.txtNum6.text];
    NSDictionary* sendsms = [[NSDictionary alloc] initWithObjectsAndKeys:Apikey, @"apikey", phone, @"phone", smscode, @"smscode", nil];
    NSDictionary* sendsmsD = [[NSDictionary alloc] initWithObjectsAndKeys:sendsms, @"active", nil];
    if ([NSJSONSerialization isValidJSONObject:sendsmsD]) {
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:sendsmsD options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableData* tempJsonData = [NSMutableData dataWithData:jsonData];
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
        [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:tempJsonData];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(activeUserSuc:)];
        [request setDidFailSelector:@selector(activeUserFaied:)];
        [request startAsynchronous];
    }
}
//请求结果
- (void)activeUserSuc:(ASIHTTPRequest*)req
{
}
- (void)activeUserFaied:(ASIHTTPRequest*)req
{
}

//在屏幕上显示两秒的提示信息
- (void)AlertMsg:(NSString*)msg
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.minSize = CGSizeMake(132.f, 108.0f);
    [hud hide:YES afterDelay:2];
}

- (IBAction)sendcode:(id)sender
{

    [[self appDelegate].time setFireDate:[NSDate distantPast]];
    counttime = 60 + 60 * smscount;
    smscount++;

    [self.txt resignFirstResponder];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.tag = 1000;
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = NSLocalizedString(@"lbFsendsms", nil);
    [HUD show:YES];

    NSURL* url = [NSURL URLWithString:[Tool Append:IMReasonableAPP witnstring:@"SendSmsCode"]];
    NSString* Apikey = IMReasonableAPPKey;
    NSString* phone = [NSString stringWithFormat:@"%@%@", userdata.countrycode, userdata.phonenumber];
    NSDictionary* sendsms = [[NSDictionary alloc] initWithObjectsAndKeys:Apikey, @"apikey", phone, @"phone", nil];
    NSDictionary* sendsmsD = [[NSDictionary alloc] initWithObjectsAndKeys:sendsms, @"phone", nil];
    if ([NSJSONSerialization isValidJSONObject:sendsmsD]) {
        NSError* error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:sendsmsD options:NSJSONWritingPrettyPrinted error:&error];
        NSMutableData* tempJsonData = [NSMutableData dataWithData:jsonData];
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
        [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:tempJsonData];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(sendSmsSuc:)];
        [request setDidFailSelector:@selector(sendSmsFaied:)];
        [request startAsynchronous];
    }
}

- (void)changetime:(NSTimer*)time
{

    //倒计时时间
    __block int timeout = counttime;
    if (timeout == 0) {
        [[self appDelegate].time setFireDate:[NSDate distantFuture]];
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置界面的按钮显示 根据自己需求设置

            [self.resect setTitle:NSLocalizedString(@"lbRectsms", nil) forState:UIControlStateNormal];
            self.resect.enabled = YES;

            [self.progress setProgress:0.0];
            self.progress.hidden = YES;

        });
    }
    else {
        int seconds = timeout % 1000;
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置界面的按钮显示 根据自己需求设置
          
            [self.resect setTitle:[NSString stringWithFormat:NSLocalizedString(@"lbRectsmsWait", nil), seconds] forState:UIControlStateNormal];
            self.resect.enabled = NO;
            self.progress.hidden = NO;
            
            float step = ((60 + 60 * (smscount - 1)) - seconds) / (float)(60 + 60 * (smscount - 1));
            [self.progress setProgress:step animated:YES];
        

        });

        counttime--;
    }
}

- (void)sendSmsSuc:(ASIHTTPRequest*)req
{
    // [AnimationHelper removeHUD];
    [HUD removeFromSuperview];
    [self.txt becomeFirstResponder];
    NSData* responsedata = [req responseData];
    NSDictionary* dict = [Tool jsontodate:responsedata];
    PJLog(@"%@", dict);

    NSString* code = [dict objectForKey:@"SendSmsResult"];
    if ([@"2" isEqualToString:code]) {

        [self AlertMsg:NSLocalizedString(@"lbSendsmsSucc", nil)];
    }
    else {

        smscount > 0 ? smscount-- : smscount == 0;
        [[self appDelegate].time setFireDate:[NSDate distantFuture]];
        self.progress.hidden = YES;
        [self.resect setTitle:NSLocalizedString(@"lbRectsms", nil) forState:UIControlStateNormal];
        self.resect.enabled = YES;
        if ([@"-1" isEqualToString:code]) {
            [self AlertMsg:NSLocalizedString(@"lbtimes", nil)];
        }
        [self AlertMsg:NSLocalizedString(@"lbsmsFailed", nil)];
    }
}

- (void)sendSmsFaied:(ASIHTTPRequest*)req
{
    //发送失败后需要
    [HUD removeFromSuperview];
    [self.txt becomeFirstResponder];

    smscount > 0 ? smscount-- : smscount == 0;
    [[self appDelegate].time setFireDate:[NSDate distantFuture]];
    self.progress.hidden = YES;
    [self.resect setTitle:NSLocalizedString(@"lbRectsms", nil) forState:UIControlStateNormal];
    self.resect.enabled = YES;

    PJLog(@"%@", [req error]);
    [self AlertMsg:NSLocalizedString(@"lbsmsFailed", nil)];
}
//发送邮件
- (IBAction)callme:(id)sender
{

    // [Tool alert:@"正在拨打电话号码"];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://10086"]];

    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));

    if (mailClass != nil) {
        if ([mailClass canSendMail]) {
            [self displayComposerSheet];
        }
        else {
            [self launchMailAppOnDevice];
        }
    }
    else {
        [self launchMailAppOnDevice];
    }
}

//可以发送邮件的话
- (void)displayComposerSheet
{
    MFMailComposeViewController* mailPicker = [[MFMailComposeViewController alloc] init];

    mailPicker.mailComposeDelegate = self;

    //设置主题
    [mailPicker setSubject:@"IMReasonable"];

    // 添加发送者
    NSArray* toRecipients = [NSArray arrayWithObject:IMMailName];
    
    [mailPicker setToRecipients:toRecipients];
   

    NSString* emailBody = @"eMail body";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentViewController:mailPicker animated:YES completion:nil];
}
- (void)launchMailAppOnDevice
{
    
    NSString* body = @"&body=email body!";

    NSString* email = [NSString stringWithFormat:@"mailto:%@&subject=IMReasonable%@", IMMailName, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    PJLog(@"%u", result);
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
}

@end
