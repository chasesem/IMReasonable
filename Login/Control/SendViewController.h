//
//  SendViewController.h
//  IMReasonable
//
//  Created by apple on 15/1/9.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <MessageUI/MFMailComposeViewController.h>

/**
 *  输入短信验证码界面
 */

@interface SendViewController : UIViewController<UITextFieldDelegate,AuthloginDelegate,MBProgressHUDDelegate,MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *Title1;
@property (weak, nonatomic) IBOutlet UILabel *Title2;

@property (weak, nonatomic) IBOutlet UITextField *txtNum1;

@property (weak, nonatomic) IBOutlet UITextField *txtNum2;
@property (weak, nonatomic) IBOutlet UITextField *txtNum3;
@property (weak, nonatomic) IBOutlet UITextField *txtNum4;
@property (weak, nonatomic) IBOutlet UITextField *txtNum5;
@property (weak, nonatomic) IBOutlet UITextField *txtNum6;

@property (weak, nonatomic) IBOutlet UINavigationItem *nav;

@property (weak, nonatomic) IBOutlet UIButton *resect;

@property (weak, nonatomic) IBOutlet UIButton *callme;

- (IBAction)sendcode:(id)sender;
- (IBAction)callme:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txt;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@end
