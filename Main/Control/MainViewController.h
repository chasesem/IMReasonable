//
//  MainViewController.h
//  IMReasonable
//
//  Created by apple on 14/12/22.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>

@interface MainViewController : UITabBarController<AuthloginDelegate>
{

BOOL _hasRegister;
}

@property (nonatomic) ABAddressBookRef addressBook;

@end
