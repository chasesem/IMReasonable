//
//  NewGroupViewController.h
//  IMReasonable
//
//  Created by apple on 15/3/17.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewGroupViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UINavigationItem *nav;

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *next;
- (IBAction)GoNext:(id)sender;

- (IBAction)GoBack:(id)sender;
@end
