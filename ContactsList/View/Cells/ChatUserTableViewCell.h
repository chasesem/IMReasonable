//
//  ChatUserTableViewCell.h
//  IMReasonable
//
//  Created by apple on 14/12/23.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatUserTableViewCell : UITableViewCell
@property (retain, nonatomic)  UIImageView *userphoto;
@property (retain, nonatomic)  UILabel *username;
@property (retain, nonatomic)  UILabel *phoneown;
@property (retain, nonatomic)  UILabel *device;
@property (retain, nonatomic)  UIButton *invite;
@end
