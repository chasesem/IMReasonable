//
//  ThirdViewController.m
//  IMReasonable
//
//  Created by apple on 15/1/12.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "RespreadSoapTool.h"
#import "ThirdViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "AnimationHelper.h"
#import <AddressBook/AddressBook.h>
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"

#define MOVE_HEIGHT 130 //键盘移动的值

@interface ThirdViewController () {
    /// NSMutableArray * friends;

    BOOL isneedchange;
}

@end

@implementation ThirdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    
    self.hidesBottomBarWhenPushed=YES;
    self.emailPrompt.text=NSLocalizedString(@"EMAIL_PROMPT", nil);
    self.txtName.placeholder=NSLocalizedString(@"REQUIRED", nil);
    self.email.placeholder=NSLocalizedString(@"REQUIRED", nil);
    isneedchange = false;

    [self.img.layer setBorderWidth:1]; //设置头像选择边框
    //设置边框线的颜色
    [self.img.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];

    self.nav.title = NSLocalizedString(@"lbTTile", nil);

    NSString* imagename = [[NSUserDefaults standardUserDefaults] objectForKey:XMPPMYFACE];
    UIImage* tempimg = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:imagename]];
    self.img.image = tempimg;

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* locaname = [defaults objectForKey:MyLOCALNICKNAME];
    NSString* localemail = [defaults objectForKey:MyEmail];
    self.txtName.text = locaname;
    self.email.text = localemail;

    //为调试用 设置这个名字会弹出设备的Token
    if ([locaname isEqualToString:@"__PJ"]) {
        NSString* token = [defaults stringForKey:@"DeviceToken"];
        [Tool alert:token];
    }

    self.txtmsg.text = NSLocalizedString(@"lbmsgTitle", nil);
    if (![XMPPDao sharedXMPPManager].xmppStream.isConnected) {
        [[XMPPDao sharedXMPPManager] connect];
    }
    [[XMPPDao sharedXMPPManager] getAllMyRoom]; //服务器拉取所有的群
    if (self.isSetting) {
        self.navigationItem.title = NSLocalizedString(@"lbTTile", nil);
        UIBarButtonItem* right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doDone:)];
        // right.tintColor=[UIColor colorWithRed:0.13 green:0.67 blue:0.22 alpha:1]; 改成青绿色
        self.navigationItem.rightBarButtonItem = right;
    }
    else {
        [self GetContacts];
    }

    //监听键盘状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //监听输入法状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

//判断键盘是否挡住输入框
- (void)MoveView:(CGFloat)keyheight
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    __block CGRect rect = self.view.frame;
    if ((rect.origin.y >= 0) && ((height - keyheight <= self.txtName.frame.origin.y) || (height - keyheight <= self.email.frame.origin.y))) {

        [UIView animateWithDuration:0.3
                         animations:^{
                             rect.origin.y -= MOVE_HEIGHT;
                             [self.view setFrame:rect];
                         }];
    }
}

#pragma mark Notification
//keyBoard已经展示出来
- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    //键盘的大小
    CGSize pjSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size; //得到鍵盤的高度
    [self MoveView:pjSize.height];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    CGRect rect = self.view.frame;
    if (rect.origin.y < 0) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             //动画的内容
                             CGRect rect = self.view.frame;
                             rect.origin.y += MOVE_HEIGHT;
                             [self.view setFrame:rect];
                         }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.txtName resignFirstResponder];
    [self.email resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//在这个函数里面创建数据库并获取扫描联系人
- (void)GetContacts
{

    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        // [AnimationHelper showHUD:NSLocalizedString(@"lblookforfriend",nil)];

        ABAddressBookRef tmpAddressBook = nil;
        //根据系统版本不同，调用不同方法获取通讯录
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
            tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error) {
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        if (tmpAddressBook == nil) {
            return;
        };

        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);

        NSString* myphone = [[[[NSUserDefaults standardUserDefaults] objectForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];

        //在这里边获取所有的联系人
        for (int i = 0; i < CFArrayGetCount(results); i++) {
            ABRecordRef person = CFArrayGetValueAtIndex(results, i);
            //读取firstname
            NSString* firstname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            //读取lastname
            NSString* lastname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);

            NSString* fullname;

            NSInteger personID = ABRecordGetRecordID(person);

            if ([Tool isHaveChinese:firstname]) {
                fullname = [NSString stringWithFormat:@"%@%@", lastname ? lastname : @"", firstname ? firstname : @""];
            }
            else {
                fullname = [NSString stringWithFormat:@"%@ %@", firstname ? firstname : @"", lastname ? lastname : @""];
            }

            //读取电话多值
            ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (int k = 0; k < ABMultiValueGetCount(phone); k++) {
                NSString* personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
                //  获取該Label下的电话值
                NSString* tmpPhoneIndex = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);

                NSString* unknowphone = [tmpPhoneIndex substringWithRange:NSMakeRange(0, 1)];
                tmpPhoneIndex = [Tool getPhoneNumber:tmpPhoneIndex];
                NSString* flag = @"0";
                if (![tmpPhoneIndex isEqualToString:@""]) {

                    if (![unknowphone isEqualToString:@"+"]) { //需要当前用户的国家代码
                        NSString* countrycode = [[NSUserDefaults standardUserDefaults] objectForKey:XMPPUSERCOUNTRYCODE];
                        tmpPhoneIndex = [NSString stringWithFormat:@"%@%@", countrycode, tmpPhoneIndex];
                    }

                    if (![tmpPhoneIndex isEqualToString:myphone]) { //过滤掉自己的电话号码
                        [[XMPPDao sharedXMPPManager] XMPPAddFriendSubscribe:tmpPhoneIndex]; //不管是不是openfire的用户得发送邀请
                        [IMReasonableDao saveUserLocalNick:tmpPhoneIndex image:fullname addid:[NSString stringWithFormat:@"%ld", (long)personID] isImrea:flag phonetitle:personPhoneLabel]; // 保存到本地数据库
                    }
                }
            }
        }

        CFRelease(results);
        CFRelease(tmpAddressBook);

        [AnimationHelper removeHUD];

        [self GetAllRegUser];

    });
}

- (void)GetAllRegUser
{
    NSMutableArray* alluser = [IMReasonableDao getAllUser];
    [[XMPPDao sharedXMPPManager] checkUser:alluser];
}

//判断电话号码是否不是openfire账户;true  是  fase 不是
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

- (IBAction)btn:(id)sender
{ //选择图片

    //[Tool alert:@"host"];
    [self imagefromwhere];
}

#pragma mark -图片源函数
- (void)imagefromwhere
{
    UIActionSheet* action;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        action = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:NSLocalizedString(@"lbTCancle", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"lbTPhonto", nil), NSLocalizedString(@"lbTShoot", nil), nil];
    }
    else {

        action = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:NSLocalizedString(@"lbTCancle", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"lbTPhonto", nil), nil];
    }

    action.tag = 255;
    action.actionSheetStyle = UIActionSheetStyleAutomatic;
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        NSUInteger sourceType = 0;
        // 判断是否支持相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
            case 0:
                //相册
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 1:
                // 相机
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 2:
                // 取消
                return;
            }
        }
        else {
            if (buttonIndex == 0) {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            else {
                return;
            }
        }

        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = (id)self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController
                           animated:YES
                         completion:^{
                         }];
    }
}
#pragma mark -图片设置到控件
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                               }];

    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];

    self.img.image = image;
    isneedchange = YES;

    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    // 保存图片至本地，方法见下文
}

//获取总代理
- (AppDelegate*)appDelegate
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return delegate;
}

- (IBAction)doDone:(id)sender
{

    NSString* localname = self.txtName.text;
    NSString* myPassword;
    if (localname && localname.length > 0) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString *date=[Tool GetDate:@"yyyy-hh-dd"];
        //默认开启填写邮箱提示(如果用户没有填写邮箱的话)
        [defaults setBool:YES forKey:ENABLE_FILL_OUT_EMAIL_PROMPT];
        myPassword = [defaults stringForKey:XMPPREASONABLEPWD];
        [defaults setBool:false forKey:ISSIGN_OUT];
        [defaults setValue:self.txtName.text forKey:MyLOCALNICKNAME];
        [defaults setObject:@"0" forKey:CHATWALLPAPER];
        [defaults setBool:true forKey:@"FIRSTLOGIN"];

        NSString* inputemail = self.email.text;
        if (inputemail && [Tool isValidateEmail:inputemail]) {
            [AnimationHelper showHUD:@"please wait!"];
            NSString* phone = [[[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
            NSString* param = [NSString stringWithFormat:ADD_EMAIL_PARAM, RESPREAD_EMAIL, RESPREAD_PASSWORD, inputemail, phone, [Tool getDateWithFormatString:@"yyyy-MM-ddThh:mm:ss"], [Tool getDateWithFormatString:@"yyyy-MM-ddThh:mm:ss"], CONTACTS];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [RespreadSoapTool Soap:WSDL_URL
                    WithParam:param
                    success:^(id success) {
                        if (isneedchange) {
                            UIImage* img = self.img.image;
                            if (img) { //选择了图片的情况下给用户设置头像

                                if (![XMPPDao sharedXMPPManager].xmppStream.isConnected) { //判断是否连接到openfire服务器
                                    [[XMPPDao sharedXMPPManager] connect];
                                }

                                NSString* filejidstrname = [[[defaults objectForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
                                [Tool saveFileToDoc:filejidstrname fileData:UIImagePNGRepresentation(img)];
                                [[NSUserDefaults standardUserDefaults] setObject:[filejidstrname stringByAppendingString:@".png"] forKey:XMPPMYFACE];
                                UIImage* tempimg = [Tool imageCompressForSize:img targetSize:CGSizeMake(300, 300)];
                                NSData* imageData = UIImagePNGRepresentation(tempimg);
                                NSString* base64data = [Tool NSdatatoBSString:imageData];
                                NSString* jidstr = [defaults objectForKey:XMPPREASONABLEJID];
                                [[XMPPDao sharedXMPPManager] SetUserPhoto:jidstr photo:base64data];
                            }
                        }
                        [defaults setBool:YES forKey:HAS_FILL_OUT_EMAIL];
                        //保存用户填写的邮箱
                        [defaults setObject:inputemail forKey:USER_SPREAD_EMAIL];
                        [defaults setObject:myPassword forKey:XMPPREASONABLEPWD];
                        [defaults synchronize];
                        [AnimationHelper removeHUD];
                        [self goNext];
                    }
                    failure:^(NSError* error) {
                        [defaults setObject:date forKey:LAST_DATE_OF_EMAIL_PROMPT];
                        [defaults setBool:NO forKey:HAS_FILL_OUT_EMAIL];
                        [defaults removeObjectForKey:XMPPREASONABLEPWD];
                        [defaults synchronize];
                        [AnimationHelper removeHUD];
                        [Tool alert:NSLocalizedString(@"LOGIN_ERROR", nil)];
                    }];
            });
        }else if(![Tool isBlankString:inputemail]&&![Tool isValidateEmail:inputemail]){
            
            [defaults setBool:NO forKey:HAS_FILL_OUT_EMAIL];
            [self tipsMsg:NSLocalizedString(@"EMAIL_PROMPT_ERROR", nil) time:2];
            return;
        }else if([Tool isBlankString:inputemail]){
            
            [defaults setObject:date forKey:LAST_DATE_OF_EMAIL_PROMPT];
            [defaults setBool:NO forKey:HAS_FILL_OUT_EMAIL];
            [defaults synchronize];
            [self goNext];
        }
    }
    else {

        [self tipsMsg:@"lbTusername" time:1];
    }
}

- (void)tipsMsg:(NSString*)msg time:(int)time
{

    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = NSLocalizedString(msg, msg);
    hud.minSize = CGSizeMake(132.f, 108.0f);
    [hud hide:YES afterDelay:time];
}

- (void)goNext
{
    
    self.navigationItem.title = NSLocalizedString(@"lbTStile", nil);
    if (!self.isSetting) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.allowRotation = YES;
        MainViewController* mainview = [[MainViewController alloc] init];
        [self presentViewController:mainview animated:YES completion:nil];
    }
}

-(void)dealloc{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
}

@end
