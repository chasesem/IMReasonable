//
//  FirstViewController.h
//  IMReasonable
//
//  Created by apple on 15/1/8.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "loginUserData.h"
#import "AnimationHelper.h"

@interface FirstViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UINavigationItem *nav;

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *done;
- (IBAction)dodone:(id)sender;


@end
