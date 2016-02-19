//
//  CountryCodeViewController.h
//  IMReasonable
//
//  Created by apple on 15/1/8.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "loginUserData.h"

@interface CountryCodeViewController : UIViewController<UITableViewDataSource,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UINavigationItem *nav;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
- (IBAction)disview:(id)sender;


@end
