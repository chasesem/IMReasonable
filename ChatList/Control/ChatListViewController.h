//
//  ChatListViewController.h
//  IMReasonable
//
//  Created by apple on 14/11/21.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
@interface ChatListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ChatHelerpDelegate,UIActionSheetDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
   
    
}
@property  NSString * tempmsg;
@end
