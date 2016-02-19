//
//  GroupAddUserUIViewController.h
//  IMReasonable
//
//  Created by apple on 15/3/19.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectDelegate.h"
#import "IMRoomDelegate.h"

@interface GroupAddUserUIViewController : UIViewController<SelectUserDelegate,RoomHelerpDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak,nonatomic) UIImage * image;
@property  NSString * subject;

@end
