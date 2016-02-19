//
//  ThirdViewController.h
//  IMReasonable
//
//  Created by apple on 15/1/12.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThirdViewController : UIViewController<UIActionSheetDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UINavigationItem *nav;
@property (weak, nonatomic) IBOutlet UILabel *txtmsg;
@property (weak, nonatomic) IBOutlet UIImageView *img;
- (IBAction)btn:(id)sender;

- (IBAction)doDone:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *lbEmail;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UILabel *emailPrompt;

@property  BOOL isSetting;
@end
