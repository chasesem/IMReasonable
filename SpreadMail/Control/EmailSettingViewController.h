//
//  EmailSettingViewController.h
//  IMReasonable
//
//  Created by apple on 16/3/18.
//  Copyright © 2016年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMChatListModle.h"
@interface EmailSettingViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>
@property  IMChatListModle * from;
@end
