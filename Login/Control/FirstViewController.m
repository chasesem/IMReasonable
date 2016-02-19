//
//  FirstViewController.m
//  IMReasonable
//
//  Created by apple on 15/1/8
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "FirstViewController.h"
#import "HeaderTableViewCell.h"
#import "CountryTableViewCell.h"
#import "PhoneTableViewCell.h"
#import "loginUserData.h"
#import "CountryCodeViewController.h"
#import "AppDelegate.h"
#import "SendViewController.h"
#import "ASIFormDataRequest.h"
#import "DesHelper.h"
#import "ThirdViewController.h"
#import "MBProgressHUD.h"

#define SEND_SMS_FAILD @"1"//1	超过30分钟或发送次数大于3

typedef enum {
    PROMPT,//提示文字
    COUNTRY_CODE,//国家代码
    PHONE//手机号码
} PhoneAndCode;
#define SEND_SMS_SUC @"2" //发送短信验证码成功


@interface FirstViewController () {
    NSString* countru;

    NSMutableArray* allcountrycode;

    loginUserData* userdata;
    MBProgressHUD* HUD;
}
@end
@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    
    [self initData];
    [self initControl];
    self.nav.title = NSLocalizedString(@"lbFphone", nil);
}

- (AppDelegate*)appDelegate
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return delegate;
}
- (void)initData
{
    NSBundle* budle = [NSBundle mainBundle];
    NSString* path = [budle pathForResource:@"CountryList" ofType:@"plist"];
    allcountrycode = [[NSMutableArray alloc] initWithContentsOfFile:path];
    userdata = [self appDelegate].userdata;
    self.nav.rightBarButtonItem.enabled = false;
    [self.tableview reloadData];
}

- (void)initControl
{
    self.tableview.backgroundColor = [UIColor whiteColor];
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell;
    switch ([indexPath row]) {
    case PROMPT: {
        HeaderTableViewCell* tempcell =
            [[HeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"HeaderTableViewCell"];
        tempcell.msgTip.text = NSLocalizedString(@"lbmsgTip", nil); //本地化
        cell = tempcell;

    } break;
    case COUNTRY_CODE: {
        CountryTableViewCell* tempcell = [[CountryTableViewCell alloc]
              initWithStyle:UITableViewCellStyleDefault
            reuseIdentifier:@"CountryTableViewCell"];
        tempcell.lbcountry.text = userdata.countryname;
        cell = tempcell;
    }

    break;
    case PHONE: {
        PhoneTableViewCell* tempcell =
            [[PhoneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"PhoneTableViewCell"];
        tempcell.code.text =
            [NSString stringWithFormat:@"+%@", userdata.countrycode];
        tempcell.code.tag = 8;
        tempcell.code.delegate = self;
        tempcell.phonenumber.placeholder = NSLocalizedString(@"lbFphone", nil); //本地化
        [tempcell.phonenumber becomeFirstResponder];
        tempcell.phonenumber.delegate = self;
        tempcell.phonenumber.tag = 9;
        cell = tempcell;
    } break;
    default:
        break;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    return cell;
}
- (void)viewDidLayoutSubviews
{
    //去除分割线左边出现的空格
    if ([self.tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableview setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }

    if ([self.tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableview setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}
- (BOOL)textField:(UITextField*)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString*)string
{
    BOOL flag = [self validateNumber:string];
    if (textField.tag == 8 && textField.text.length == 1 &&
        [string isEqualToString:@""]) {
        return false;
    }

    if (flag) {
        NSString* tempphone =
            [[NSString alloc] initWithFormat:@"%@%@", textField.text, string];
        switch (textField.tag) {
        case 8: {
            if (userdata.countrycode.length <= 3) {
                if ([tempphone rangeOfString:@"+"].location != NSNotFound) //_roaldSearchText
                {
                    userdata.countrycode = [tempphone substringFromIndex:1];
                }
                else {
                    userdata.countrycode = tempphone;
                }

                if ([string isEqualToString:@""]) {
                    userdata.countrycode = [tempphone
                        substringWithRange:NSMakeRange(1, tempphone.length - 2)];
                }

                NSLog(@"%@", userdata.countrycode);
            }
            else {
                if ([string isEqualToString:@""]) {
                    userdata.countrycode = [tempphone
                        substringWithRange:NSMakeRange(1, tempphone.length - 2)];
                    NSLog(@"%@", userdata.countrycode);

                }

                flag = false;
            }

            NSPredicate* predicate = [NSPredicate
                predicateWithFormat:@"Vaule == %@", userdata.countrycode];
            NSArray* filteredArray =
                [allcountrycode filteredArrayUsingPredicate:predicate];
            if (filteredArray.count > 0) {
                NSDictionary* dict = [filteredArray objectAtIndex:0];
                [self appDelegate].userdata.countryname = NSLocalizedString([dict objectForKey:@"Key"], nil);
                NSString* vaule = [dict objectForKey:@"Vaule"];
                [self appDelegate].userdata.countrycode = vaule;

                userdata = [self appDelegate].userdata;
                [self.tableview reloadData];
            }

        } break;
        case 9: {
            userdata.phonenumber = tempphone;
            self.nav.title = [NSString
                stringWithFormat:@"+%@  %@", userdata.countrycode, tempphone];
             if (tempphone.length > 0 && tempphone.length < 13) {
                self.nav.rightBarButtonItem.enabled = true;
                flag = true;
            }
            else {
                self.nav.rightBarButtonItem.enabled = false;
                flag = false;
            }

            if ([string isEqualToString:@""] && self.nav.title.length == 1 + 3 + [userdata.countrycode length] && textField.tag == 9) {
                self.nav.title = NSLocalizedString(@"lbFphone", nil);
                self.nav.rightBarButtonItem.enabled = false;
            }

        } break;
        }
    }
    return flag;
}

- (BOOL)validateNumber:(NSString*)number
{
    BOOL res = YES;
    NSCharacterSet* tmpSet =
        [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
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
- (void)tableView:(UITableView*)tableView
    didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([indexPath row] == 1) {
        CountryCodeViewController* firstview = [[CountryCodeViewController alloc]
            initWithNibName:@"CountryCodeViewController"
                     bundle:nil];
        [self presentViewController:firstview animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch ([indexPath row]) {
    case PROMPT: {
        return 80;
    } break;
    case COUNTRY_CODE: {
        return 44;

    } break;
    case PHONE: {
        return 44;

    } break;

    default:
        return 44;
        break;
    }
}

- (IBAction)dodone:(id)sender
{
    NSString* msg =
        [NSString stringWithFormat:NSLocalizedString(@"lbactionmsg", nil),
                  userdata.countrycode, userdata.phonenumber];
    UIAlertView* alert = [[UIAlertView alloc]
            initWithTitle:NSLocalizedString(@"lbactionTitle", nil)
                  message:msg
                 delegate:self
        cancelButtonTitle:NSLocalizedString(@"lbactionRight", nil)
        otherButtonTitles:NSLocalizedString(@"lbactionLeft", nil), nil];

    [self hidekeboard];
    if ([userdata.countrycode isEqualToString:@"86"] ||
        [userdata.countrycode isEqualToString:@"852"]) {
        if ([Tool isCHMobileNumber:userdata.phonenumber]) {
            [alert show];
        }
        else if ([Tool isHKMobileNumber:userdata.phonenumber]) {
            [alert show];
        }
        else {
            [self AlertMsg:NSLocalizedString(@"lbphonenumbererr", nil)];
        }
    }
    else {
        [alert show];
    }
}

//隐藏键盘
- (void)hidekeboard
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    PhoneTableViewCell* tempcell = (PhoneTableViewCell*)[self.tableview cellForRowAtIndexPath:indexPath];

    UITextField* phonenumber;
    UITextField* cotunrycode;

    for (UIView* view in tempcell.contentView.subviews) {
        if (view.tag == 8) {
            cotunrycode = (UITextField*)view;
            [cotunrycode resignFirstResponder];
            NSLog(@"%@", cotunrycode.text);
        }
        if (view.tag == 9) {
            phonenumber = (UITextField*)view;
            [phonenumber resignFirstResponder];
        }
    }
}
//显示键盘
- (void)showkeboard
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    PhoneTableViewCell* tempcell = (PhoneTableViewCell*)[self.tableview cellForRowAtIndexPath:indexPath];

    UITextField* phonenumber;
    for (UIView* view in tempcell.contentView.subviews) {
        if (view.tag == 9) {
            phonenumber = (UITextField*)view;

            [phonenumber becomeFirstResponder];
        }
    }
}

- (void)alertView:(UIAlertView*)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSPredicate* predicate =
            [NSPredicate predicateWithFormat:@"Vaule == %@", userdata.countrycode];
        NSArray* filteredArray =
            [allcountrycode filteredArrayUsingPredicate:predicate];

        if (userdata.countrycode.length > 0 && userdata.phonenumber.length > 0 && filteredArray.count > 0) {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.tag = 1000;
            HUD.mode = MBProgressHUDModeIndeterminate;
            HUD.labelText = NSLocalizedString(@"lbFsendsms", nil);
            //  HUD.square = YES;
            [HUD show:YES];

            // [AnimationHelper showHUD:NSLocalizedString(@"lbFsendsms", nil)];
            //发送短信
            NSURL* url = [NSURL URLWithString:[Tool Append:IMReasonableAPP
                                                  witnstring:@"SendSmsCode"]];
            NSString* Apikey = IMReasonableAPPKey;
            NSString* phone = [NSString
                stringWithFormat:@"%@%@", userdata.countrycode, userdata.phonenumber];
            if ([userdata.countrycode isEqualToString:@"1"] && userdata.phonenumber.length == 11) {
                phone = userdata.phonenumber;
            }

            NSDictionary* sendsms = [[NSDictionary alloc]
                initWithObjectsAndKeys:Apikey, @"apikey", phone, @"phone", nil];
            NSDictionary* sendsmsD =
                [[NSDictionary alloc] initWithObjectsAndKeys:sendsms, @"phone", nil];
            if ([NSJSONSerialization isValidJSONObject:sendsmsD]) {
                NSError* error;
                NSData* jsonData =
                    [NSJSONSerialization dataWithJSONObject:sendsmsD
                                                    options:NSJSONWritingPrettyPrinted
                                                      error:&error];
                NSMutableData* tempJsonData = [NSMutableData dataWithData:jsonData];
                ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
                [request addRequestHeader:@"Content-Type"
                                    value:@"application/json; encoding=utf-8"];
                [request addRequestHeader:@"Accept" value:@"application/json"];
                [request setRequestMethod:@"POST"];
                [request setPostBody:tempJsonData];
                [request setDelegate:self];
                [request setDidFinishSelector:@selector(sendSmsSuc:)];
                [request setDidFailSelector:@selector(sendSmsFaied:)];
                [request startAsynchronous];
            }
        }
        else {
            [self showkeboard];
            [self AlertMsg:NSLocalizedString(@"lbmsgTip", nil)];
        }
    }
}
 
- (void)sendSmsSuc:(ASIHTTPRequest*)req
{
    NSData* responsedata = [req responseData];
    NSDictionary* dict = [Tool jsontodate:responsedata];

    NSLog(@"SendSmsResult:%@", dict);

    NSString* code = [dict objectForKey:@"SendSmsCodeResult"];
    /**
     *  如果测试时短信发送次数过多不能发送了这边直接设置成true即可
     *
     *  @param isEqualToString:code]
     *
     *  @return
     */
    //[SEND_SMS_SUC isEqualToString:code]
    if ([SEND_SMS_SUC isEqualToString:code]) {
        [HUD removeFromSuperview];
        SendViewController* firstview =
            [[SendViewController alloc] initWithNibName:@"SendViewController"
                                                 bundle:nil];
        //跳转到输入短信验证码界面
        [self presentViewController:firstview animated:YES completion:nil];
    }else if([SEND_SMS_FAILD isEqualToString:code]){
        
        [HUD removeFromSuperview];
        [self AlertMsg2:NSLocalizedString(@"SEND_SMS_FAILD", nil)];
    }
    else {
        [HUD removeFromSuperview];
        [self AlertMsg:NSLocalizedString(@"lbsmsFailed", nil)];
    }
}

- (void)sendSmsFaied:(ASIHTTPRequest*)req
{
    [HUD removeFromSuperview];
    [self showkeboard];
    NSLog(@"%@", [req error]);
    if ([XMPPDao sharedXMPPManager].isConnectInternet) {
        [self AlertMsg:NSLocalizedString(@"lbsmsFailed", nil)];
    }
    else {
        [self AlertMsg:NSLocalizedString(@"msgInternet", nil)];
    }
}

- (void)AlertMsg2:(NSString*)msg
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText=msg;
    hud.labelFont=[UIFont systemFontOfSize:12];
    hud.minSize = CGSizeMake(100.0f, 100.0f);
    [hud hide:YES afterDelay:2];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
}

@end
