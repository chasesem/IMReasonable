//
//  GroupSetViewController.h
//  IMReasonable
//
//  Created by apple on 15/4/21.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupSetTableViewCell.h"
#import "GroupUserTableViewCell.h"
#import "AddGroupUserTableViewCell.h"
#import "IMChatListModle.h"
#import "IMDelegate.h"

@interface GroupSetViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,RoomDelegate>


@property  IMChatListModle * from;
@end
