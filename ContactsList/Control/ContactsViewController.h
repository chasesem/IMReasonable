//
//  FavoritesViewController.h
//  IMReasonable
//
//  Created by apple on 14/12/22.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface ContactsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ChatHelerpDelegate,ABPeoplePickerNavigationControllerDelegate,UIActionSheetDelegate,MFMessageComposeViewControllerDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UIAlertViewDelegate>

@end
